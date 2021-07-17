#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

can_exec=0

[ -z "$LABELS" ] && can_exec=1 && write_error "LABELS not set in label_pr"
# && exit 1
[ -z "$ID" ] && can_exec=1 && write_error "ID not set in label_pr"
# && exit 1
[ -z "$GITHUB_REPOSITORY" ] && can_exec=1 && write_error "GITHUB_REPOSITORY not set in label_pr"
# && exit 1
[ -z "$GITHUB_REPOSITORY_OWNER" ] && can_exec=1 && write_error "GITHUB_REPOSITORY_OWNER not set in label_pr"
# && exit 1

labels=($(echo -e $LABELS | tr ',' '\n'))

printf "labels:\n"
printf "\t%s\n" $labels

json_data=$(printf "%s\n" "${labels[@]}" | jq -R . | jq -s .)
printf "json_data: \n%s\n" "$json_data"

args=( --url )
args+=('repos/{owner}/{repo}/issues/{id}/labels')
args+=(--method)
args+=(POST)
args+=(--auth)
args+=(--json-body)
args+=($(echo $json_data))
args+=(--id)
args+=($ID)
args+=(--repo)
args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
args+=(--owner)
args+=($GITHUB_REPOSITORY_OWNER)

printf "args:\n"
printf "\t%s\n" $args

printf "\n\nARGS:\n\n"
printf "\t${args[@]}\n\n"

echo

[ $can_exec -ne 0 ] && write_error "can_exec -ne 0..." && exit 1

git_req -d $args[@]

# results=($(git_req ${args[@]}))
# printf "exit_code: \n\t%d\n" ${results[0]}
# echo "${results[@]:1}" | jq
# before_exit
# exit 0
