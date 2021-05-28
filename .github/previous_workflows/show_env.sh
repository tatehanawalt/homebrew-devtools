#!/bin/bash

. "$(dirname $0)/helpers.sh"

env_csv=$(join_by , $(env | grep -o '^[^[:space:]].*' | sed 's/=.*//' | sort))
groups=($(printf "$INSPECT_GROUPS\nenv=$env_csv\n"| sed 's/^[[:space:]]*//' | sed '/^$/d' | sort))
write_result_set "$(join_by , $(printf "%s\n" ${groups[@]} | sed 's/=.*//'))" inspect_groups
for entry in ${groups[@]}; do
  kv=($(echo "$entry" | tr -d '[[:space:]]' | tr '=' '\n'))
  log ${kv[0]}
  for_csv ${kv[1]} print_field
done
for entry in ${groups[@]}; do
  kv=($(echo "$entry" | tr -d '[[:space:]]' | tr '=' '\n'))
  max_field_len=$(csv_max_length ${kv[1]})
  log ${kv[0]}_table
  for_csv ${kv[1]} print_field_table
done
before_exit

# exit 0
# DO NOT DELETE - USEFUL FOR DEBUGGING!
# log VERSIONS
# command_log_which bash "$(bash --version)"
# command_log_which brew "$(brew --version)"
# command_log_which git "$(git --version)"
# command_log_which jq "$(jq --version)"
# export INSPECT_GROUPS='
#     git=GITHUB_ACTION,GITHUB_ACTIONS,GITHUB_ACTION_REF,GITHUB_ACTION_REPOSITORY,GITHUB_ACTOR,GITHUB_API_URL,GITHUB_BASE_REF,GITHUB_ENV,GITHUB_EVENT_NAME,GITHUB_EVENT_PATH,GITHUB_GRAPHQL_URL,GITHUB_HEAD_REF,GITHUB_JOB,GITHUB_PATH,GITHUB_REF,GITHUB_REPOSITORY,GITHUB_REPOSITORY_OWNER,GITHUB_RETENTION_DAYS,GITHUB_RUN_ID,GITHUB_RUN_NUMBER,GITHUB_SERVER_URL,GITHUB_SHA,GITHUB_WORKFLOW,GITHUB_WORKSPACE
#     formula=FORMULA_NAMES,FORMULA_PATHS,FORMULA_STABLE_SHAS,FORMULA_HEAD_SHAS,FORMULA_STABLE_URLS,FORMULA_HEAD_URLS
# '
