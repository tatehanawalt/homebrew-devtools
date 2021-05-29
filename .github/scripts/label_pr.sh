#!/bin/bash

. "$(dirname $0)/helpers.sh" ${@}

IFS=$'\n'
args=(--url)
args+=('repos/{owner}/{repo}/issues/{id}/labels')
args+=(--method)
args+=(POST)
args+=(--labels_csv)
args+=("$LABELS")
args+=(--id)
args+=($ID)
args+=(--repo)
args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
args+=(--owner)
args+=($GITHUB_REPOSITORY_OWNER)
results=($(args ${args[@]}))
printf "exit_code: %d\n" ${results[0]}
echo "${results[@]:1}" | jq
before_exit
exit 0
