#!/bin/bash

src_path=$(dirname $0)
. "$src_path/helpers.sh"

# env_csv=$(join_by , $(env | grep -o '^[^[:space:]].*' | sed 's/=.*//' | sort))
# INSPECT_GROUPS=$(printf "$INSPECT_GROUPS\nenv=$env_csv\n"| sed 's/^[[:space:]]*//' | sed '/^$/d')
printf "$INSPECT_GROUPS\nenv=$env_csv\n"| sed 's/^[[:space:]]*//' | sed '/^$/d'


exit
# groups=($(echo "$INSPECT_GROUPS" | sed 's/=.*$//' | sort))


print_field() {
  printf "%s=$(eval "echo \"\$$1\"")\n" $1
}
print_field_table() {
  printf "\t%-${max_field_len}s " "$1:"
  field_val=$(eval "echo \"\$$1\"" | tr ',' '\n')
  field_val=($(eval "echo \"\$$1\"" | tr ',' '\n' | sed 's/^[[:space:]]*//g'))
  [ ${#field_val[@]} -ne 1 ] && printf "\n"
  [ ${#field_val[@]} -gt 1 ] && local_prefix="$(get_prefix)   - "
  for entry in ${field_val[@]}; do printf "$local_prefix%s\n" $entry; done
}

for entry in "${groups[@]}"; do
  group_fields=$(echo "${INSPECT_GROUPS[@]}" | grep -o "$entry[^ ]*" | sed 's/.*=//')
  max_field_len=$(csv_max_length $group_fields)
  log "$entry" && for_csv $group_fields print_field
  log "${entry}_table" && for_csv $group_fields print_field_table
done



exit


# groups=()
# for entry in "${INSPECT_GROUPS[@]}"; do groups+=($(echo $entry | sed 's/=.*$//')); done
# printf "\n$INSPECT_GROUPS\n\n"
# write_result_set "$(join_by , ${groups[@]})" inspect_groups
# log ENV
# for_csv $env_csv print_field
# log ENV_TABLE
# for_csv $env_csv print_field_table
#   for entry in "${INSPECT_GROUPS[@]}"; do
#     group=$(echo $entry | sed 's/=.*//')
#     fields=$(echo $entry | sed 's/.*=//')
#     inspect_fields "$group" "$fields"
#   done
# Pass this function the set of comma-separated keys to inspect the environment
# variable value of each key
# inspect_fields() {
#   log "$1"
#   fields=($(printf "%s" "$2" | sed 's/^,//' | sed 's/,$//' | tr ',' '\n' | sort -u | sed '/^$/d' | sed 's/^[[:space:]]//g'))
#   max_field_len=0
#   for key in ${fields[@]}; do
#     key_len=${#key}
#     [ $key_len -gt $max_field_len ] && max_field_len=$(($key_len + 1))
#     printf "%s=%s\n" $key "$(eval "echo \"\$$key\"")"
#   done
# }
# inspect_fields_table() {
#   log "${1}_table"
#   IFS=$'\n'
#   for key in ${fields[@]}; do
#     keyval=($( eval "echo -e \"\$$key\"" | tr ',' '\n' | sed 's/^[[:space:]]*//g'))
#     local_prefix=""
#     printf "$(get_prefix)%-${max_field_len}s " "$key:"
#     [ ${#keyval[@]} -ne 1 ] && printf "\n"
#     [ ${#keyval[@]} -gt 1 ] && local_prefix="$(get_prefix)   - "
#     for entry in ${keyval[@]}; do printf "$local_prefix%s\n" $entry; done
#   done
# }
#
# inspect_fields ENV $(printf "%s" "$(env)" | sed 's/^[[:space:]].*//g' | sed '/^$/d' | sed 's/=.*//g' | tr '\n' ',')
# inspect_fields_table ENV $(printf "%s" "$(env)" | sed 's/^[[:space:]].*//g' | sed '/^$/d' | sed 's/=.*//g' | tr '\n' ',')
#
# if [ ! -z "$INSPECT_GROUPS" ]; then
#   INSPECT_GROUPS=($(echo $INSPECT_GROUPS | sed 's/^[^[:alpha:]]*//g' | sed '/^$/d' | tr ' ' '\n'))
#   groups=()
#   for entry in "${INSPECT_GROUPS[@]}"; do groups+=($(echo $entry | sed 's/=.*$//')); done
#   write_result_set "$(join_by , ${groups[@]})" inspect_groups
#   for entry in "${INSPECT_GROUPS[@]}"; do
#     group=$(echo $entry | sed 's/=.*//')
#     fields=$(echo $entry | sed 's/.*=//')
#     inspect_fields "$group" "$fields"
#   done
# fi
#
# before_exit
# exit 0


# [ ! -z "$INSPECT_ENV_FIELDS" ] && inspect_fields INSPECT_ENV_FIELDS $INSPECT_ENV_FIELDS
#  keyval=($(eval "echo -e \"\$$key\"" | tr ',' '\n'))
# [ -z "$keyval" ] && continue
#  printf "$(get_prefix)%-${max_field_len}s %s\n" "$key:" "$keyval"
#  continue
#fi
# [ ${#keyval[@]} -le 1 ] && printf "%s\n" "$keyval" && continue
# [ -z "${#keyval[@]}" ] && echo
# [ ${#keyval[@]} -gt  ] && echo
# printf "%s\n" "$keyval" && continue
# write_result_set "$(join_by , ${groups[@]})" inspect_groups
# export INSPECT_GROUPS='
#
#     git=GITHUB_ACTION,GITHUB_ACTIONS,GITHUB_ACTION_REF,GITHUB_ACTION_REPOSITORY,GITHUB_ACTOR,GITHUB_API_URL,GITHUB_BASE_REF,GITHUB_ENV,GITHUB_EVENT_NAME,GITHUB_EVENT_PATH,GITHUB_GRAPHQL_URL,GITHUB_HEAD_REF,GITHUB_JOB,GITHUB_PATH,GITHUB_REF,GITHUB_REPOSITORY,GITHUB_REPOSITORY_OWNER,GITHUB_RETENTION_DAYS,GITHUB_RUN_ID,GITHUB_RUN_NUMBER,GITHUB_SERVER_URL,GITHUB_SHA,GITHUB_WORKFLOW,GITHUB_WORKSPACE
#
#     formula=FORMULA_NAMES,FORMULA_PATHS,FORMULA_STABLE_SHAS,FORMULA_HEAD_SHAS,FORMULA_STABLE_URLS,FORMULA_HEAD_URLS
#
# '

# DO NOT DELETE - USEFUL FOR DEBUGGING!
# log VERSIONS
# command_log_which bash "$(bash --version)"
# command_log_which brew "$(brew --version)"
# command_log_which git "$(git --version)"
# command_log_which jq "$(jq --version)"
