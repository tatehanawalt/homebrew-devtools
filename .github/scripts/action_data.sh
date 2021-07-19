#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

[ ! -f "$GITHUB_EVENT_PATH" ] && write_error "$(basename $0) GITHUB_EVENT_PATH file not found at $GITHUB_EVENT_PATH - line $LINENO" && exit 1

event_file_attributes=($(cat $GITHUB_EVENT_PATH | jq -r 'keys | join("\n")'))
event_file_attributes_csv=$(join_by , ${event_file_attributes[@]})
event_file=$(cat $GITHUB_EVENT_PATH | jq)
REPOSITORY_JSON=$(cat $GITHUB_EVENT_PATH | jq '.repository')
REPOSITORY_ID=$(echo "$REPOSITORY_JSON" | jq -r '.id')
REPO=$(echo "$REPOSITORY_JSON" | jq -r '.name')

log EVENT_$GITHUB_EVENT_NAME

echo "$event_file"

echo -e "\n"

write_result_set "$event_file_attributes_csv" event_file_attributes
write_result_set "$REPOSITORY_ID" "REPOSITORY_ID"
write_result_set "$REPO" "REPO"

case $GITHUB_EVENT_NAME in
  pull_request)
    PULL_REQUEST_JSON=$(cat $GITHUB_EVENT_PATH | jq '.pull_request')
    ID=$(cat $GITHUB_EVENT_PATH | jq '.number')
    OWNER=$(printf "%s" "$GITHUB_REPOSITORY" | sed 's/\/.*//')
    labels_str=$(printf "%s" "$PULL_REQUEST_JSON" | jq -r '.labels | map(.name) | join(",")')

    printf "\nlabels_str: %s\n" $labels_str

    write_result_set "$ID" ID
    write_result_set $(join_by , $OWNER) OWNER
    write_result_set "${labels_str[@]}" LABELS
    ;;
  push)
    printf "PUSH:\n"
    ;;
  workflow_dispatch)
    printf "WORKFLOW_DISPATCH:\n"
    ;;
  *)
    write_error "$(basename $0) Unhandled GITHUB_EVENT_NAME $GITHUB_EVENT_NAME - line $LINENO"
    exit 1
    ;;
esac

before_exit

exit 0
