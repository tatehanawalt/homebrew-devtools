#!/bin/bash

. "$(dirname $0)/helpers.sh"


# DEFAULT_LABELS='[{
# 		"name": ":beer:",
# 		"description": "Somehow related to homebrew",
# 		"color": "F28E1C"
# 	},
# 	{
# 		"name": ":bug: Bug",
# 		"description": "Literally a bug",
# 		"color": "ffd438"
# 	},
# 	{
# 		"name": ":alien: Unidentified",
# 		"description": "Something is unknown",
# 		"color": "ffd438"
# 	},
# 	{
# 		"name": ":roboot:",
# 		"description": "Robots are working on it!",
# 		"color": "814fff"
# 	},
# 	{
# 		"name": ":zap:",
# 		"description": "A robot fixed something",
# 		"color": "24a0ff"
# 	}
# ]'







# echo  "$DEFAULT_LABELS" | jq




# exit
# [ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
# [ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
# [ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
# [ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
# [ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
# [ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
# [ -z "$OWNER" ]                   && OWNER="$GITHUB_REPOSITORY_OWNER"
# [ -z "$REPO" ]                    && REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')

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


# . "$(dirname $0)/helpers.sh" ${@}
# 
# IFS=$'\n'
# args=(--url)
# args+=('repos/$OWNER/$REPO/issues/$ID/labels')
# args+=(--labels_csv)
# args+=("$LABELS")
# args+=(--id)
# args+=($ID)
# args+=(--repo)
# args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
# args+=(--owner)
# args+=($GITHUB_REPOSITORY_OWNER)
# results=($(label_pr ${args[@]}))
# printf "exit_code: %d\n" ${results[0]}
# echo "${results[@]:1}" | jq
# before_exit
# exit 0




for label in ${create_labels[@]}; do
  result=$(create_label "$label")
  exit_status=$?
  echo $result | jq -r | jq
done

before_exit
exit 0
