#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

args=(--url)
args+=('repos/{owner}/{repo}/issues/{id}/labels')
args+=(--method)
args+=(POST)


labels=($(echo -e $LABELS | tr , '\n'))
echo "labels:"
printf "\t%s\n" ${labels[@]}
json_data=$(printf "%s\n" "${labels[@]}" | jq -R . | jq -s .)
printf "\njson_data\n${json_data}\n"

args+=(--json-body)
args+=("$json_data")
args+=(--id)
args+=($ID)
args+=(--repo)
args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
args+=(--owner)
args+=($GITHUB_REPOSITORY_OWNER)

printf "\t%s\n" ${args[@]}

git_req ${args[@]}

before_exit
exit 0

# args+=(--labels_csv)
# args+=("$LABELS")
# results=($(args ${args[@]}))
# printf "exit_code: %d\n" ${results[0]}
# echo "${results[@]:1}" | jq
# IFS=$'\n'
