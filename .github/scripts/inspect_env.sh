#!/bin/sh

# Used as a debugging script to see what an environment looks like
#
# Specify INSPECT_ENV_FIELDS=<field>,<field2>... to see a list of specific
# fields

# Specify a specific set with INSPECT_ENV_FIELDS=<field>,<field2>... to see a list of specific
#
# or specify groups of inspect sets with
# INSPECT_GROUPS='
#   groupname1=<key1>,<key2...>
#   groupname2=<key1>,<key2...>
# '
# Where groupname is the name of the group
# for example:
# INSPECT_GROUPS='
#   git_env=GITHUB_ACTION,GITHUB_ACTIONS,GITHUB_ACTION_REF,GITHUB_ACTION_REPOSITORY,GITHUB_ACTOR,GITHUB_API_URL,GITHUB_BASE_REF,GITHUB_ENV,GITHUB_EVENT_NAME,GITHUB_EVENT_PATH,GITHUB_GRAPHQL_URL,GITHUB_HEAD_REF,GITHUB_JOB,GITHUB_PATH,GITHUB_REF,GITHUB_REPOSITORY,GITHUB_REPOSITORY_OWNER,GITHUB_RETENTION_DAYS,GITHUB_RUN_ID,GITHUB_RUN_NUMBER,GITHUB_SERVER_URL,GITHUB_SHA,GITHUB_WORKFLOW,GITHUB_WORKSPACE"
#   user_env=DIFF_BRANCH,DIFF_FILES,DIFF_DIRS,DIFF_FORMULA,LABELS
# '

# DO NOT MODIFY IFS!
IFS="
"

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
in_log=0
log() {
  if [ $in_log -ne 0 ]; then
    echo "::endgroup::";
    in_log=0
  fi
  if [ ! -z "$1" ]; then
    echo "::group::$1";
    in_log=1
  fi
}

# Pass this function the set of comma-separated keys to inspect the environment
# variable value of each key
inspect_fields() {
  log $1
  fields=$(printf "%s" "$2" | sed 's/^,//' | sed 's/,$//' | tr ',' '\n' | sort -u )
  max_field_len=0
  for key in ${fields}; do
    [ ${#key} -gt $max_field_len ] && max_field_len=${#key}
    printf "%s=%s\n" $key $(eval "echo \"\$$key\"")
  done
  log "${1}_TABLE"
  for key in ${fields}; do
    printf "%-${max_field_len}s - %s\n" $key $(eval "echo \"\$$key\"")
  done
  log
}

inspect_fields ENV $(printf "%s" "$(env)" | sed 's/=.*//g' | tr '\n' ',')
[ ! -z "$INSPECT_ENV_FIELDS" ] && inspect_fields INSPECT_ENV_FIELDS $INSPECT_ENV_FIELDS

if [ ! -z "$INSPECT_GROUPS" ]; then
  log inspect_groups
  groups=$(printf "%s" "$INSPECT_GROUPS" | sed '/^$/d' | sed 's/[[:space:]]*$//g')
  echo "inspect_groups:"
  for group in ${groups}; do
    group=$(printf "%s" $group | xargs)
    #tr -d ' '
    gkey=$(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]')

    printf "\tkey:\t%s\n" $gkey
    # [ ! -z "$gkey" ] && inspect_fields $gkey $(printf "%s" "$group" | sed 's/.*=//')
  done
  log
fi


#export INSPECT_GROUPS='
#  git_env=GITHUB_ACTION,GITHUB_ACTIONS,GITHUB_ACTION_REF,GITHUB_ACTION_REPOSITORY,GITHUB_ACTOR,GITHUB_API_URL,GITHUB_BASE_REF,GITHUB_ENV,GITHUB_EVENT_NAME,GITHUB_EVENT_PATH,GITHUB_GRAPHQL_URL,GITHUB_HEAD_REF,GITHUB_JOB,GITHUB_PATH,GITHUB_REF,GITHUB_REPOSITORY,GITHUB_REPOSITORY_OWNER,GITHUB_RETENTION_DAYS,GITHUB_RUN_ID,GITHUB_RUN_NUMBER,GITHUB_SERVER_URL,GITHUB_SHA,GITHUB_WORKFLOW,GITHUB_WORKSPACE
#  user_env=DIFF_BRANCH,DIFF_FILES,DIFF_DIRS,DIFF_FORMULA,LABELS
#  '


exit 0
