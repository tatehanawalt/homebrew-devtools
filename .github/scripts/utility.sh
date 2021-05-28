#!/bin/bash

. "$(dirname $0)/helpers.sh"

# UTILITY provides multiple utility functions for processing raw data
# this script probably shouldn't call any apis or anything...
[ $HAS_TEMPLATE -ne 0 ] && echo "NO TEMPLATE SPECIFIED" && exit 1

case $template in
  # Check which of the $KEYS (csv) are not in the $SET (csv)
  keys_not_in_set)
    # TESTING:
    # export template=keys_not_in_set
    # export SET='brew,bug,democ,democpp,demogolang,demonodejs,demopython,demozsh,devenv,documentation,duplicate,enhancement,formula,good first issue,help wanted,invalid,ops,question,wontfix'
    # export KEYS='demozsh,devenv,donotfindmeinset,ialso do not exist'
    set_fields=($(echo -e "${SET[@]}" | tr ',' '\n'))
    key_fields=($(echo -e "${KEYS[@]}" | tr ',' '\n'))
    printf "set_fields:\n"
    printf "\t%s\n" ${set_fields[@]} | sort -u
    printf "\n"
    printf "key_fields:\n"
    printf "\t%s\n" ${key_fields[@]} | sort -u
    printf "\n"
    printf "checking keys:\n"
    result_keys=()
    for key in ${key_fields[@]}; do
      contains "$key" "${set_fields[@]}"
      [ $? -ne 0 ] && result_keys+=($key)
    done
    printf "\n"
    write_result_set $(join_by , "${result_keys[@]}")
    ;;
  *)
    printf "UNHANDLED TARGET: $1"
    exit 1
    ;;
esac

exit 0
