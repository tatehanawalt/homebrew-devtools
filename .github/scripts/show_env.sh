#!/bin/bash

. "$GITHUB_WORKSPACE/.github/scripts/helpers.sh"


# Pass this function the set of comma-separated keys to inspect the environment
# variable value of each key

inspect_fields() {
  log $1
  fields=($(printf "%s" "$2" | sed 's/^,//' | sed 's/,$//' | tr ',' '\n' | sort -u | sed '/^$/d' | sed 's/^[[:space:]]//g'))
  max_field_len=0
  for key in ${fields[@]}; do
    key_len=${#key}
    [ $key_len -gt $max_field_len ] && max_field_len=$(($key_len + 1))
    printf "%s=%s\n" $key "$(eval "echo \"\$$key\"")"
  done

  log $1_table
  for key in ${fields[@]}; do
    keyval=($(eval "echo -e \"\$$key\"" | tr ',' '\n'))
    if [ ${#keyval[@]} -lt 2 ]; then
      printf "$prefix%-${max_field_len}s %s\n" "$key:" "$keyval"
      continue
    fi
    printf "$prefix%-${max_field_len}s\n" "$key:"
    for entry in ${keyval[@]}; do printf "$prefix   - %s\n" $entry; done
  done
}

inspect_fields ENV $(printf "%s" "$(env)" | sed 's/^[[:space:]].*//g' | sed '/^$/d' | sed 's/=.*//g' | tr '\n' ',')
[ ! -z "$INSPECT_ENV_FIELDS" ] && inspect_fields INSPECT_ENV_FIELDS $INSPECT_ENV_FIELDS

INSPECT_GROUPS=($(echo "$INSPECT_GROUPS" | tr [[:space:]] '\n' | sed 's/^[^[:alpha:]]*//g' | sort))
[ -z "$INSPECT_GROUPS" ] && exit 0

groups=()
for entry in "${INSPECT_GROUPS[@]}"; do groups+=($(echo $entry | sed 's/=.*//')); done
write_result_set $(join_by , ${groups[@]}) inspect_groups

for entry in "${INSPECT_GROUPS[@]}"; do
  group=$(echo $entry | sed 's/=.*//')
  fields=$(echo $entry | sed 's/.*=//')
  write_result_set $fields $group_group
  inspect_fields $group $fields
done

exit 0

# DO NOT DELETE - USEFUL FOR DEBUGGING!
# log VERSIONS
# command_log_which bash "$(bash --version)"
# command_log_which brew "$(brew --version)"
# command_log_which git "$(git --version)"
# command_log_which jq "$(jq --version)"


# INSPECT_GROUPS=$(echo "$INSPECT_GROUPS" | sed 's/^[^[:alpha:]]*//g')

# groups=($(echo "${INSPECT_GROUPS[@]}" | sed 's/^[^[:alpha:]]*//g'))

# group_names=()
# for group in ${groups[@]}; do group_names+=($(printf "%s\n" $group | sed 's/=.*//')); done
# write_result_set $groups group_names
# group_names=($(echo $INSPECT_GROUPS | sed 's/=[^[:space:]]*//g' | tr -s ' ' | tr ' ' '\n' | sort -u))
# write_result_set $(join_by , ${group_names[@]}) group_names


# $(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]') $(printf "%s" "$group" | sed 's/.*=//')
# for group in ${groups[@]}; do
#   group=$(printf "%s" "$group" | xargs)
#   inspect_fields $(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]') $(printf "%s" "$group" | sed 's/.*=//')
# done
# export INSPECT_GROUPS='
#             specific=DIFF_FORMULA,LABELS,DIFF_FILES,DIFF_DIRS,PR_LABELS,PR_ID,PR_ADD_LABELS
#             git_env=GITHUB_ACTION,GITHUB_ACTIONS,GITHUB_ACTION_REF,GITHUB_ACTION_REPOSITORY,GITHUB_ACTOR,GITHUB_API_URL,GITHUB_BASE_REF,GITHUB_ENV,GITHUB_EVENT_NAME,GITHUB_EVENT_PATH,GITHUB_GRAPHQL_URL,GITHUB_HEAD_REF,GITHUB_JOB,GITHUB_PATH,GITHUB_REF,GITHUB_REPOSITORY,GITHUB_REPOSITORY_OWNER,GITHUB_RETENTION_DAYS,GITHUB_RUN_ID,GITHUB_RUN_NUMBER,GITHUB_SERVER_URL,GITHUB_SHA,GITHUB_WORKFLOW,GITHUB_WORKSPACE
# '
