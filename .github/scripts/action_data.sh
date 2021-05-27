#!/bin/bash

. $GITHUB_WORKSPACE/.github/scripts/helpers.sh

printf "inc"
in_log=0
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally

log EVENT_FILE
if [ -f "$GITHUB_EVENT_PATH" ]; then
  cat $GITHUB_EVENT_PATH | jq
else
  printf "GITHUB_EVENT_PATH FILE NOT FOUND\n"
  printf "GITHUB_EVENT_PATH=%s\n" "$GITHUB_EVENT_PATH"
  exit 1
fi

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
