#!/bin/bash
# Used as a debugging script to see what an environment looks like

# DO NOT MODIFY IFS!
IFS="
"
prefix="\t"
in_log=0
in_ci=1

# IF RUN BY CI vs Locally
[ "$CI" = "true" ] && in_ci=0
[ $in_ci -eq 0 ] && prefix=""

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
log() {
  if [ $in_log -ne 0 ]; then
    [ $in_ci -eq 0 ] && echo "::endgroup::";
    in_log=0
  fi
  # Do we need to start a group?
  if [ ! -z "$1" ]; then
    [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1:"
    in_log=1
  fi
}

log VERSIONS
echo "BASH:"
printf "\t%s\n" $(bash --version)
printf "\t- %s\n" $(which bash)
echo
echo "BREW:"
printf "\t%s\n" $(brew --version)
printf "\t- %s\n" $(which brew)
echo
echo "GIT:"
printf "\t%s\n" $(git --version)
printf "\t- %s\n" $(which git)
echo
echo "JQ:"
printf "\t%s\n" $(jq --version)
printf "\t- %s\n" $(which jq)
echo

# Normalize input inspect_groups
[ ! -z "$INSPECT_GROUPS" ] && INSPECT_GROUPS=$(printf "%s" "$INSPECT_GROUPS" | sed "s/  */\n/g" | sed '/^$/d' | sed 's/^[^[:space:]]/\t&/')

# Pass this function the set of comma-separated keys to inspect the environment
# variable value of each key
inspect_fields() {
  log $1
  fields=($(printf "%s" "$2" | sed 's/^,//' | sed 's/,$//' | tr ',' '\n' | sort -u | sed '/^$/d'))
  max_field_len=0
  for key in ${fields[@]}; do
    key_len=${#key}
    [ $key_len -gt $max_field_len ] && max_field_len=$(($key_len + 1))
    printf "$prefix%s=%s\n" $key "$(eval "echo \"\$$key\"")"
  done
  log "${1}_TABLE"
  for key in ${fields[@]}; do
    keyval=($(eval "echo -e \"\$$key\"" | tr ',' '\n'))
    if [ ${#keyval[@]} -lt 2 ]; then
      printf "%-${max_field_len}s %s\n" "$key:" "$keyval"
      continue
    fi
    printf "%-${max_field_len}s\n" "$key:"
    for entry in ${keyval[@]}; do printf "\t     - %s\n" $entry; done
  done
}

inspect_fields ENV $(printf "%s" "$(env)" | sed 's/^[[:space:]].*//g' | sed '/^$/d' | sed 's/=.*//g' | tr '\n' ',')
[ ! -z "$INSPECT_ENV_FIELDS" ] && inspect_fields INSPECT_ENV_FIELDS $INSPECT_ENV_FIELDS
if [ ! -z "$INSPECT_GROUPS" ]; then
  log INSPECT_GROUPS
  groups=$(printf "%s" "$INSPECT_GROUPS" | sed 's/^[[:space:]]*//g' | sed '/^$/d' )
  for group in $groups; do
    group=$(printf "%s" "$group" | xargs)
    printf "\t%s\n" "$(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]')"
  done
  for group in $groups; do
    group=$(printf "%s" "$group" | xargs)
    inspect_fields $(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]') $(printf "%s" "$group" | sed 's/.*=//')
  done
fi
log

exit 0
