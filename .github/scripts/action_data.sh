#!/bin/bash

. "$(dirname $0)/helpers.sh"

if [ ! -f "$GITHUB_EVENT_PATH" ]; then
  write_error "$(basename $0) GITHUB_EVENT_PATH file not found at $GITHUB_EVENT_PATH - line $LINENO"
  exit 1
fi

event_file_attributes=($(cat $GITHUB_EVENT_PATH | jq -r 'keys | join("\n")'))
event_file_attributes_csv=$(join_by , ${event_file_attributes[@]})
event_file=$(cat $GITHUB_EVENT_PATH | jq -r 'keys | join("\n")')
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
    write_error "$(basename $0) Unhandled Extension $ext - line $LINENO"
    exit 1
    ;;
esac
before_exit
exit 0

# printf "event_file_attributes: %d\n" ${#event_file_attributes[@]}
# printf "\t%s\n" ${event_file_attributes[@]}
# printf "%s" $event_file_attributes_csv

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

# log PULL_REQUEST
# AFTER -> NEW COMMIT
# BEFORE -> OLD COMMIT
# printf "GITHUB_REF=%s\n" "$GITHUB_REF"
