#!/bin/bash

. "$(dirname $0)/helpers.sh"

[ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
[ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
[ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
[ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
[ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
[ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
[ -z "$OWNER" ]                   && OWNER="$GITHUB_REPOSITORY_OWNER"
[ -z "$REPO" ]                    && REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
IFS=$'\n'
current_labels=($(printf "%s\n" "${CURRENT_LABELS[@]}" | tr , '\n' | tr [[:upper:]] [[:lower:]] | sort -u))
write_result_set $(join_by , ${current_labels[@]}) current_labels

add_labels=($(printf "%s\n" "${ADD_LABELS[@]}" | tr , '\n' | tr [[:upper:]] [[:lower:]] | sort -u))
write_result_set $(join_by , "${add_labels[@]}") add_labels

create_labels=()
for label in "${add_labels[@]}"; do
  add=$(contains "$label" "${current_labels[@]}")
  exit_code=$?
  [ $exit_code -eq 0 ] && continue
  create_labels+=( "$label" )
done
write_result_set $(join_by , "${create_labels[@]}") create_labels

for label in ${create_labels[@]}; do
  result=$(create_label "$label")
  exit_status=$?
  # echo "response code: $?"
  echo $result | jq -r | jq
done
