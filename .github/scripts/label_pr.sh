#!/bin/bash

# Test Data
#
# export GITHUB_REPOSITORY=homebrew-devtools
# export GITHUB_REPOSITORY_OWNER=tatehanawalt
# export ID=21
#

my_path=$0
. "$(dirname $my_path)/helpers.sh"

can_exec=0

args=( --url )
args+=('repos/{owner}/{repo}/issues/{id}/labels')
args+=(--method)
args+=(POST)
args+=(--auth)

if [ -z "$GITHUB_REPOSITORY" ];
then
  can_exec=1
  write_error "GITHUB_REPOSITORY not set in label_pr"
else
  args+=(--repo)
  args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
fi

if [ -z "$GITHUB_REPOSITORY_OWNER" ]
then
  can_exec=1
  write_error "GITHUB_REPOSITORY_OWNER not set in label_pr"
else
  args+=(--owner)
  args+=($GITHUB_REPOSITORY_OWNER)
fi

if [ -z "$ID" ]
then
  can_exec=1
  write_error "ID not set in label_pr"
else
  args+=(--id)
  args+=($ID)
fi

if [ -z "$LABELS" ]
then
  can_exec=1
  write_error "LABELS not set in label_pr"
else
  labels=($(echo -e $LABELS | tr ',' '\n'))

  printf "%s\n" ${labels[@]} | jq -R . | jq -s -c .

  json_data=$(printf "%s\n" "${labels[@]}" | jq -R . | jq -s -c .)


  printf "json_data: %s\n" "${json_data[@]}"

  # json_data=$(printf "%s\n" "${labels[@]}" | jq -R . | jq -s .)

  args+=(--json-body)
  args+=($json_data)
  # args+=($(echo $json_data))
fi

printf "args: ${#args[@]}\n"
printf "\t%s\n" ${args[@]}
echo
printf "%s " ${args[@]}
echo

# [ $can_exec -ne 0 ] && write_error "can_exec -ne 0..." && exit 1
# args+=(-d)

git_req "${args[@]}"

# results=($(git_req ${args[@]}))
# printf "exit_code: \n\t%d\n" ${results[0]}
# echo "${results[@]:1}" | jq
# before_exit
# exit 0
