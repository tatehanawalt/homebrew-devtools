#!/bin/bash

# HEAD is the branch
# BASE is the main

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
join_by () {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}";
  fi;
}
write_result_set() {
  result="$1"
  result=$(echo -e "$result" | sed 's/"//g')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  KEY="RESULT"
  [ ! -z "$2" ] && KEY="$2"
  echo "$KEY:"
  echo $result
  echo "::set-output name=$KEY::$(echo -e $result)"
}

log EVENT_FILE
if [ -f "$GITHUB_EVENT_PATH" ]; then
  cat $GITHUB_EVENT_PATH | jq
else
  printf "GITHUB_EVENT_PATH FILE NOT FOUND\n"
  printf "GITHUB_EVENT_PATH=%s\n" "$GITHUB_EVENT_PATH"
  exit 1
fi
log

log PRE_EVENT
printf "GITHUB_EVENT_NAME=%s\n" "$GITHUB_EVENT_NAME"
REPOSITORY_JSON=$(cat $GITHUB_EVENT_PATH | jq '.repository')




REPOSITORY_ID=$(echo "$REPOSITORY_JSON" | jq -r '.id')
write_result_set "$REPOSITORY_ID" "REPOSITORY_ID"

REPO=$(echo "$REPOSITORY_JSON" | jq -r '.name')
write_result_set "$REPO" "REPO"

log
case $GITHUB_EVENT_NAME in
  pull_request)
    log PULL_REQUEST
    printf "GITHUB_REF=%s\n" "$GITHUB_REF"

    PULL_REQUEST_JSON=$(cat $GITHUB_EVENT_PATH | jq '.pull_request')

    ID=$(cat $GITHUB_EVENT_PATH | jq '.number')
    write_result_set "$ID" "ID"

    OWNER=$(printf "%s" "$GITHUB_REPOSITORY" | sed 's/\/.*//')
    write_result_set "$OWNER" "OWNER"

    LABELS=$(printf "%s" "$PULL_REQUEST_JSON" | jq -r '.labels | map(.name) | join(",")')
    write_result_set "$LABELS" "LABELS"
    ;;
  *)
    printf "\n\nUNHANDLED GITHUB_EVENT_NAME GITHUB_EVENT_NAME\n"
    printf "GITHUB_EVENT_NAME=%s\n" "$GITHUB_EVENT_NAME"
    exit 1
    ;;
esac



log
exit 0

# GIT_ENV
# GITHUB_ACTION=run4
# GITHUB_ACTIONS=true
# GITHUB_ACTION_REF=
# GITHUB_ACTION_REPOSITORY=
# GITHUB_ACTOR=tatehanawalt
# GITHUB_API_URL=https://api.github.com
# GITHUB_BASE_REF=main


# GITHUB_ENV=/home/runner/work/_temp/_runner_file_commands/set_env_155ef002-28b0-4248-b07b-8c3fd0378d0f
# GITHUB_EVENT_PATH=/home/runner/work/_temp/_github_workflow/event.json
# GITHUB_GRAPHQL_URL=https://api.github.com/graphql
# GITHUB_HEAD_REF=check_new_labels
# GITHUB_JOB=inspect-env
# GITHUB_PATH=/home/runner/work/_temp/_runner_file_commands/add_path_155ef002-28b0-4248-b07b-8c3fd0378d0f
# GITHUB_REF=refs/pull/14/merge
# GITHUB_REPOSITORY=tatehanawalt/homebrew-devtools
# GITHUB_REPOSITORY_OWNER=tatehanawalt
# GITHUB_RETENTION_DAYS=3
# GITHUB_RUN_ID=879324506
# GITHUB_RUN_NUMBER=2
# GITHUB_SERVER_URL=https://github.com
# GITHUB_SHA=2401fb2b0bd1b7dfcf2457619433993f8cc31023
# GITHUB_WORKFLOW=pr-formula-tag
# GITHUB_WORKSPACE=/home/runner/work/homebrew-devtools/homebrew-devtools

# SENDER_JSON=$(cat $GITHUB_EVENT_PATH | jq '.sender')
# "action",
# "after",
# "before",
# "number",
# "pull_request",
# "repository",
# "sender"

# TESTING:
# export GITHUB_EVENT_NAME=pull_request
# export GITHUB_REPOSITORY=tatehanawalt/homebrew-devtools
# export GITHUB_REF=refs/pull/14/merge
# export GITHUB_EVENT_PATH=/Users/tatehanawalt/Documents/dev/dev_doc/event.json

# cat $GITHUB_EVENT_PATH | jq 'keys'
# cat $GITHUB_EVENT_PATH | jq '.action'
# cat $GITHUB_EVENT_PATH | jq '.before'
# cat $GITHUB_EVENT_PATH | jq '.after'
# cat $GITHUB_EVENT_PATH | jq '.sender'

# LABELS=$(echo "$PULL_REQUEST_JSON" | jq '.labels')
# REPO=$(printf "%s" "$GITHUB_REPOSITORY" | sed 's/.*\///')
# printf "REPO=%s\n" "$REPO"
# printf "\n"

# echo "$PULL_REQUEST_JSON" | jq
# curl \
#   -H "Accept: application/vnd.github.v3+json" \
#   https://api.github.com/repos/octocat/hello-world/pulls/42

#LABELS=$(printf "%s" $PULL_REQUEST_JSON | jq '.labels[]? | [.name] | join(",")')
# printf "%s" "$PULL_REQUEST_JSON" | jq '.labels[]? | .name'
