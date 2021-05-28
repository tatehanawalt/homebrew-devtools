#!/bin/bash

. "$(dirname $0)/helpers.sh" ${@}

labels_csv=${LABELS[@]}
labels=($(echo -e "${LABELS[@]}" | tr ',' '\n'))
write_result_set "$labels_csv" LABEL_PR_LABELS

data=$(printf "[%s]" $(printf "\"%s\"," "${labels[@]}" | sed 's/,$//'))
[ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
[ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
[ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
[ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
[ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
[ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
OWNER="$GITHUB_REPOSITORY_OWNER"
REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')
REQUEST_URL="https://api.github.com/repos/$OWNER/$REPO/issues/$ID/labels"

printf "ID=%s\n" "$ID"
printf "LABELS=%s\n" "$LABELS"
printf "data: %s\n" "$data"
printf "REQUEST_URL=%s\n" "$REQUEST_URL"

response=$(curl \
  -X POST \
  -s \
  -w "HTTPSTATUS:%{http_code}" \
  -H "Authorization: token $GITHUB_AUTH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "$REQUEST_URL" \
  -d "$data" )

before_exit
exit 0
