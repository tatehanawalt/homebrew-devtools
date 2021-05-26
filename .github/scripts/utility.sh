#!/bin/bash

# UTILITY provides multiple utility functions for processing raw data
# this script probably shouldn't call any apis or anything...

IFS="
"
if [ -z "$template" ]; then
  [ ! -z "$1" ] && template="$1"
  if [ -z "$template" ]; then
    echo "NO TEMPLATE SPECIFIED"
    exit 1
  fi
fi

DIFF_FORMULA=demozsh,devenv

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
in_log=0
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally
log() {
  [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
  in_log=0
  [ -z "$1" ] && return # Input specified we do not need to start a new log group
  [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
  in_log=1
}
join_by () {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}";
  fi;
}
write_result_set() {
  result="$1"
  result=$(echo -e "$result" | sed 's/"//g')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  KEY="RESULT"
  [ ! -z "$2" ] && KEY="$2"
  echo "$KEY:"
  echo $result
  echo "::set-output name=$KEY::$(echo -e $result)"
}

contains() {
  check=$1
  shift
  [[ $@ =~ (^|[[:space:]])$check($|[[:space:]]) ]] && return 0 || return 1
}

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
    printf "key_fields:\n"
    printf "\t%s\n" ${key_fields[@]} | sort -u

    result_keys=()
    for key in ${key_fields[@]}; do
      printf "\t%s\n" "$key"
      contains "$key" "${set_fields[@]}"
      [ $? -ne 0 ] && result_keys+=($key)
    done
    write_result_set $(join_by , "${result_keys[@]}")
    exit 0
    ;;
  *)
      printf "UNHANDLED TARGET: $1"
      exit 1
    ;;
esac
