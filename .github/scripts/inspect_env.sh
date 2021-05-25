#!/bin/sh

# Used as a debugging script to see what an environment looks like
#
# Specify INSPECT_ENV_FIELDS=<field>,<field2>... to see a list of specific
# fields

ENV_MAP=$(env)
MAX_KEY_LEN=0

echo "::group::ENV"
printf "%s\n" "$ENV_MAP"
echo "::endgroup::"
IFS="
"
ENV_MAP=$(echo "$ENV_MAP" | sort)

echo "::group::ENV_TRAVERSE"
  for entry in ${ENV_MAP}; do
    key=$(echo "$entry" | sed 's/=.*//')
    [ ${#key} -gt $MAX_KEY_LEN ] && MAX_KEY_LEN=${#key}
    printf "\t%s=%s\n" "$key" $(eval "echo \"\${$key}\"")
  done
echo "::endgroup::"

# Table output
echo "::group::ENV_TABLE"
  for entry in ${ENV_MAP}; do
    key=$(echo "$entry" | sed 's/=.*//')
    printf "\t%-${MAX_KEY_LEN}s - %s\n" "$key" $(eval "echo \"\${$key}\"")
  done
echo "::endgroup::"

if [ ! -z "$INSPECT_ENV_FIELDS" ]; then
  INSPECT_ENV_FIELDS=$(echo "$INSPECT_ENV_FIELDS" | tr ',' '\n' | sort -u)
  echo "::group::INSPECT_ENV_FIELDS"
  for key in ${INSPECT_ENV_FIELDS}; do
    [ ${#key} -gt $MAX_KEY_LEN ] && MAX_KEY_LEN=${#key}
    printf "\t%s=%s\n" "$key" $(eval "echo \"\${$key}\"")
  done
  echo "::endgroup::"
  echo "::group::INSPECT_ENV_FIELDS_TABLE"
  for key in ${INSPECT_ENV_FIELDS}; do
    printf "\t%-${MAX_KEY_LEN}s - %s\n" "$key" $(eval "echo \"\${$key}\"")
  done
  echo "::endgroup::"
fi
