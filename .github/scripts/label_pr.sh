#!/bin/bash

. "$(dirname $0)/helpers.sh" ${@}

IFS=$'\n'

# testing:
GITHUB_REPOSITORY_OWNER=tatehanawalt
GITHUB_REPOSITORY=tatehanawalt/homebrew-devtools
ID=17
LABELS='test1,test2,test number 3,and_test 4'

args=(--url)
args+=('repos/$OWNER/$REPO/issues/$ID/labels')
args+=(--labels_csv)
args+=("${LABELS[@]}")
args+=(--id)
args+=($ID)
args+=(--repo)
args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
args+=(--owner)
args+=($GITHUB_REPOSITORY_OWNER)

results=($(label_pr ${args[@]}))
printf "exit_code: %d\n" ${results[0]}
echo "${results[@]:1}" | jq
before_exit
exit 0
