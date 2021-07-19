#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

can_exec=0
args=(--url)
args+=('repos/{owner}/{repo}/issues/{id}/labels')
args+=(--method)
args+=(POST)
args+=(--auth)

if [ -z "$GITHUB_REPOSITORY" ]; then
  can_exec=1
  write_error "GITHUB_REPOSITORY not set in label_pr - line $LINENO"
fi

if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
  can_exec=1
  write_error "GITHUB_REPOSITORY_OWNER not set in label_pr - line $LINENO"
fi

if [ -z "$ID" ]; then
  can_exec=1
  write_error "ID not set in label_pr - line $LINENO"
fi

if [ -z "$LABELS" ]; then
  can_exec=1
  write_error "LABELS not set in label_pr - line $LINENO"
fi

args+=(--id)
args+=($ID)

labels=($(echo -e $LABELS | tr ',' '\n'))
json_data=$(printf "%s\n" "${labels[@]}" | jq -R . | jq -s -c .)
args+=(--json-body)
args+=($json_data)

args+=(--owner)
args+=($GITHUB_REPOSITORY_OWNER)

args+=(--repo)
args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))

[ $can_exec -ne 0 ] && write_error "can_exec -ne 0 - line $LINENO" && exit 1

git_req ${args[@]}

before_exit
