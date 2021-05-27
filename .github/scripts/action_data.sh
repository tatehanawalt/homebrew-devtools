#!/bin/bash

if [ ! -f "$GITHUB_EVENT_PATH" ]; then
  printf "GITHUB_EVENT_PATH FILE NOT FOUND\n"
  printf "GITHUB_EVENT_PATH=%s\n" "$GITHUB_EVENT_PATH"
  exit 1
fi

[ ! -z "$GITHUB_WORKSPACE" ] && \
  SCRIPTPATH="$GITHUB_WORKSPACE/.github/scripts" || \
  SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPTPATH/helpers.sh"

log EVENT_FILE
cat $GITHUB_EVENT_PATH | jq

log EVENT_$(echo $GITHUB_EVENT_NAME | tr [:lower:] [:upper:])
REPOSITORY_JSON=$(cat $GITHUB_EVENT_PATH | jq '.repository')
REPOSITORY_ID=$(echo "$REPOSITORY_JSON" | jq -r '.id')
write_result_set "$REPOSITORY_ID" "REPOSITORY_ID"
REPO=$(echo "$REPOSITORY_JSON" | jq -r '.name')
write_result_set "$REPO" "REPO"

case $GITHUB_EVENT_NAME in
  pull_request)
    # log PULL_REQUEST
    # AFTER -> NEW COMMIT
    # BEFORE -> OLD COMMIT
    # printf "GITHUB_REF=%s\n" "$GITHUB_REF"
    PULL_REQUEST_JSON=$(cat $GITHUB_EVENT_PATH | jq '.pull_request')
    ID=$(cat $GITHUB_EVENT_PATH | jq '.number')
    write_result_set "$ID" ID
    OWNER=$(printf "%s" "$GITHUB_REPOSITORY" | sed 's/\/.*//')
    write_result_set $(join_by , $OWNER) OWNER
    labels_str=$(printf "%s" "$PULL_REQUEST_JSON" | jq -r '.labels | map(.name) | join(",")')
    write_result_set "${labels_str[@]}" LABELS
    ;;
  push)
    printf "PUSH:\n"
    #printf "\n\nPUSH\n\n"
    # "after",
    # "base_ref",
    # "before",
    # "commits",
    # "compare",
    # "created",
    # "deleted",
    # "forced",
    # "head_commit",
    # "pusher",
    # "ref",
    # "repository",
    # "sender"
    ;;
  workflow_dispatch)
    printf "WORKFLOW_DISPATCH:\n"
    ;;
  *)
    printf "\n\nUNHANDLED GITHUB_EVENT_NAME GITHUB_EVENT_NAME\n"
    printf "GITHUB_EVENT_NAME=%s\n" "$GITHUB_EVENT_NAME"
    exit 1
    ;;
esac

before_exit
log
exit 0
