#!/bin/bash

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
in_log=0
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally

helpers_log_topics=()
before_exit() {
  printf "\n\nBEFORE EXIT:\n"
  for key in ${helpers_log_topics[@]}; do
    printf "\t%s\n" $key
  done

  # result="$helpers_log_topics"
  # result=$(echo -e "$result" | sed 's/"//g')
  # result="${result//'%'/'%25'}"
  # result="${result//$'\n'/'%0A'}"
  # result="${result//$'\r'/'%0D'}"



}


log() {
  [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
  in_log=0
  [ -z "$1" ] && return # Input specified we do not need to start a new log group
  [ $in_ci -eq 1 ] && echo "::group::$1" || echo "$1"
  in_log=1
}
join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }
write_result_set() {
  result="$1"
  result=$(echo -e "$result" | sed 's/"//g')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  KEY="RESULT"
  [ ! -z "$2" ] && KEY="$2"
  echo "$KEY:"
  helpers_log_topics+=($KEY)
  echo $result
  echo "::set-output name=$KEY::$(echo -e $result)"
}



# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   printf "\nwrite_result_set: $1\n"
#   printf "\nwrite_result_set: ${#@}\n"
#   echo
#   echo $result
#   echo
#   echo "::set-output name=RESULT::$(echo -e $result)"
# }
