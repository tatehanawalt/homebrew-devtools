#!/bin/sh

# Used as a debugging script to see what an environment looks like
#
# Specify INSPECT_ENV_FIELDS=<field>,<field2>... to see a list of specific
# fields

ENV_MAP=$(env)
MAX_KEY_LEN=0
IFS="
"
ENV_MAP=$(echo "$ENV_MAP" | sort)

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
log () {
  echo "::endgroup::"
  [ ! -z "$1" ] && echo "::group::$1"
}

# Log the environment
log ENV
printf "%s\n" "$ENV_MAP"

# Table output
log ENV_TABLE
for entry in ${ENV_MAP}; do
  key=$(echo "$entry" | sed 's/=.*//')
  [ ${#key} -gt $MAX_KEY_LEN ] && MAX_KEY_LEN=${#key}
done
for entry in ${ENV_MAP}; do
  key=$(echo "$entry" | sed 's/=.*//')
  printf "%-${MAX_KEY_LEN}s - %s\n" "$key" $(eval "echo \"\${$key}\"")
done

if [ ! -z "$INSPECT_ENV_FIELDS" ]; then
  INSPECT_ENV_FIELDS=$(echo "$INSPECT_ENV_FIELDS" | tr ',' '\n' | sort -u)
  log INSPECT_ENV_FIELDS
  for key in ${INSPECT_ENV_FIELDS}; do
    [ ${#key} -gt $MAX_KEY_LEN ] && MAX_KEY_LEN=${#key}
    printf "%s=%s\n" "$key" $(eval "echo \"\${$key}\"")
  done

  log INSPECT_ENV_FIELDS_TABLE
  for key in ${INSPECT_ENV_FIELDS}; do
    printf "%-${MAX_KEY_LEN}s - %s\n" "$key" $(eval "echo \"\${$key}\"")
  done
fi

log

exit 0
