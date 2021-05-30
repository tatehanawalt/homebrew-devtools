#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

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

printf "\t%s\n" ${args[@]}
# results=($(args ${args[@]}))
# printf "exit_code: %d\n" ${results[0]}
# echo "${results[@]:1}" | jq

before_exit
exit 0

# IFS=$'\n'
