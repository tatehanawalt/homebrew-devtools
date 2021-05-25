#!/bin/sh

# Used as a debugging script to see what an environment looks like
#
# Specify INSPECT_ENV_FIELDS=<field>,<field2>... to see a list of specific
# fields

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
log() { echo "::endgroup::"; [ ! -z "$1" ] && echo "::group::$1"; }

# Pass this function the set of comma-separated keys to inspect the environment
# variable value of each key
inspect_fields() {
  log $1
  shift
  fields=$(printf "%s" "$1" | \
    sed 's/^,//' | \
    sed 's/,$//' | \
    tr ',' '\n' | \
    sort -u | \
    sed '/^[[:space:]]*$/d')

  max_field_len=0
  for key in ${fields}; do
    [ ${#key} -gt $max_field_len ] && max_field_len=${#key}
    printf "%s=%s\n" $key $(eval "echo \"\$$key\"")
  done
  log "$1_TABLE"
  for key in ${fields}; do
    printf "%-${max_field_len}s - %s\n" $key $(eval "echo \"\$$key\"")
  done
  log
}

# DO NOT MODIFY IFS!
IFS="
"
inspect_fields ENV $(printf "%s" "$(env)" | sed 's/=.*//g' | tr '\n' ',')
[ ! -z "$INSPECT_ENV_FIELDS" ] && inspect_fields INSPECT_ENV_FIELDS $INSPECT_ENV_FIELDS
exit 0
