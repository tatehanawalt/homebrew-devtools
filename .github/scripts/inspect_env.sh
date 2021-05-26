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
prefix="\t"
in_log=0
in_ci=1
# IF RUN BY CI vs Locally
[ "$CI" = "true" ] && prefix="" && in_ci=0
# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
log() {
  if [ $in_log -ne 0 ]; then
    if [ $in_ci -eq 0 ]; then
      echo "::endgroup::";
    fi
    in_log=0
  fi
  # Do we need to start a group?
  if [ ! -z "$1" ]; then
    if [ $in_ci -eq 0 ]; then
      echo "::group::$1";
    else
      echo "$1:"
    fi
    in_log=1
  fi
}

# Normalize input inspect_groups
[ ! -z "$INSPECT_GROUPS" ] && INSPECT_GROUPS=$(printf "%s" "$INSPECT_GROUPS" | sed "s/  */\n/g" | sed '/^$/d' | sed 's/^[^[:space:]]/\t&/')

# Pass this function the set of comma-separated keys to inspect the environment
# variable value of each key
inspect_fields() {
  log $1
  fields=$(printf "%s" "$2" | sed 's/^,//' | sed 's/,$//' | tr ',' '\n' | sort -u )
  max_field_len=0
  for key in ${fields}; do
    [ ${#key} -gt $max_field_len ] && max_field_len=${#key}
    keyval=$(eval "echo \"\$$key\"")
    printf "$prefix%s=%s\n" $key "$keyval"
  done
  log "${1}_TABLE"
  for key in ${fields}; do
    keyval=$(eval "echo \"\$$key\"")
    lines=$(echo "$keyval" | tr ',' '\n' | wc -l)
    [ $lines -lt 2 ] && printf "\t%-${max_field_len}s - %s\n" $key $keyval && continue
    # We found a csv set entry... print it in the necessary format
    entries=$(echo "$keyval" | tr ',' '\n' | tr '\t' '\n')
    printf "\t%-${max_field_len}s\n" "$key:"
    for entry in ${entries}; do printf "\t     - %s\n" $entry; done
  done
  log
}

inspect_fields ENV $(printf "%s" "$(env)" | sed 's/^[[:space:]].*//g' | sed '/^$/d' | sed 's/=.*//g' | tr '\n' ',')
[ ! -z "$INSPECT_ENV_FIELDS" ] && inspect_fields INSPECT_ENV_FIELDS $INSPECT_ENV_FIELDS

if [ ! -z "$INSPECT_GROUPS" ]; then
  groups=$(printf "%s" "$INSPECT_GROUPS" | sed 's/^[[:space:]]*//g' | sed '/^$/d' )
  log INSPECT_GROUPS
  for group in $groups; do
    group=$(printf "%s" "$group" | xargs)
    gkey=$(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]')
    printf "\t%s\n" "$gkey"
  done
  log
  for group in $groups; do
    group=$(printf "%s" "$group" | xargs)
    gkey=$(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]')
    inspect_fields $gkey $(printf "%s" "$group" | sed 's/.*=//')
  done
fi
log

exit 0
