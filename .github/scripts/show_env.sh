#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPTPATH/helpers.sh"





log VERSIONS
command_log_which bash "$(bash --version)"
command_log_which brew "$(brew --version)"
command_log_which git "$(git --version)"
command_log_which jq "$(jq --version)"


# echo "BASH:"
# printf "$prefix%s\n" "$(bash --version)"
# printf "$prefix%s %s\n" "-" $(which bash)
# echo "BREW:"
# printf "$prefix%s\n" "$(brew --version)"
# printf "$prefix%s %s\n" "-" $(which brew)
# echo "GIT:"
# printf "$prefix%s\n" "$(git --version)"
# printf "$prefix%s %s\n" "-" $(which git)
# echo "JQ:"
# printf "$prefix%s\n" "$(jq --version)"
# printf "$prefix%s %s\n" "-" $(which jq)

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
  log "${1}_TABLE"
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
[ -z "$INSPECT_GROUPS" ] && exit 0
groups=($(echo "${INSPECT_GROUPS[@]}" | sed 's/^[^[:alpha:]]*//g'))
log INSPECT_GROUPS
for group in ${groups[@]}; do
  group=$(printf "%s" "$group" | xargs)
  inspect_fields $(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]') $(printf "%s" "$group" | sed 's/.*=//')
done
log
exit 0
