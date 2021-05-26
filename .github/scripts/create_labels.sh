#!/bin/bash
IFS="
"
[ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
[ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
[ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
[ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
[ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
[ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
TOPIC=repos
[ -z "$OWNER" ] && OWNER="$GITHUB_REPOSITORY_OWNER"
[ -z "$REPO" ] && REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')
# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
in_log=0
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally
log() {
  [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
  in_log=0
  [ -z "$1" ] && return # Input specified we do not need to start a new log group
  [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
  in_log=1
}
contains() {
  check=$1
  shift
  [[ $@ =~ (^|[[:space:]])$check($|[[:space:]]) ]] && return 0 || return 1
}
existing_labels=($(echo -e "${EXISTING_LABELS[@]}" | tr ',' '\n'))
check_create_labels=($(echo -e "${CHECK_CREATE_LABELS[@]}" | tr ',' '\n'))
log EXISTING_LABELS
printf "\t%s\n" ${existing_labels[@]} | sort -u
log CHECK_LABELS
create_labels=()
for label in ${check_create_labels[@]}; do
  printf "\t%s\n" "$label"
  contains "$label" "${existing_labels[@]}"
  [ $? -ne 0 ] && create_labels+=("$label")
done
log CREATE_LABELS
printf "\t%s\n" ${create_labels[@]} | sort -u
create_label() {
  REQUEST_URL="https://api.github.com/repos/$OWNER/$REPO/labels"
  printf "REQUEST_URL: %s\n"  "$REQUEST_URL"
  data="{\"name\":\"$1\"}"

  response=$(curl \
    -X POST \
    -s \
    -w "HTTPSTATUS:%{http_code}" \
    -H "Authorization: token $GITHUB_AUTH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    $REQUEST_URL \
    -d ${data})

  output=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g' | tr '\r\n' ' ')
  request_status=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  request_status=$((${request_status} + 0))
  [ $request_status -eq 200 ] && request_status=0
  echo $output | jq --arg response_code "$request_status" '. += {"response_code":$response_code}'
  [ $request_status -eq 200 ] && return 0
  [ $request_status -eq 201 ] && return 0
  return 1
}

printf "OWNER: %s\n" "$OWNER"
printf "REPO: %s\n"  "$REPO"

log CREATE_LABELS
echo
for label in ${create_labels[@]}; do
  printf "+ $label\n"
  create_label "$label"
  if [ $? -ne 0 ]; then
    exit 1
    log
  fi
done
echo
log