#!/bin/bash

. "$(dirname $0)/helpers.sh"

DEFAULT_LABELS="$(default_labels)"

# ADD_LABELS
add_labels=($(printf "%s\n" "${ADD_LABELS[@]}" | tr , '\n' | tr [[:upper:]] [[:lower:]] | sort -u))
for label in "${add_labels[@]}"; do
  DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq \
    --arg name "$label" \
    '. | . + [{"name": $name}]')
done

for row in $(echo "${DEFAULT_LABELS}" | jq -r '.[] | @base64'); do
  dataJson=$(echo ${row} | base64 --decode)
  IFS=$'\n'
  args=(--url)
  args+=('repos/$OWNER/$REPO/labels')
  args+=(--method)
  args+=(POST)
  args+=(--repo)
  args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
  args+=(--owner)
  args+=($GITHUB_REPOSITORY_OWNER)
  args+=(--json-body)
  args+=($(echo ${row} | base64 --decode))
  results=($(git_req ${args[@]}))
  printf "\nexit_code: %d\n\n%s\n" ${results[0]}
  echo "${results[@]:1}" | jq
  printf "\n"
done
