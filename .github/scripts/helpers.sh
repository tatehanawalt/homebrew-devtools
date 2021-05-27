#!/bin/bash

Black='\033[0;30m'
DarkGray='\033[1;30m'
Red='\033[0;31m'
LightRed='\033[1;31m'
Green='\033[0;32m'
LightGreen='\033[1;32m'
BrownOrange='\033[0;33m'
Yellow='\033[1;33m'
Blue='\033[0;34m'
LightBlue='\033[1;34m'
Purple='\033[0;35m'
LightPurple='\033[1;35m'
Cyan='\033[0;36m'
LightCyan='\033[1;36m'
LightGray='\033[0;37m'
White='\033[1;37m'

# No Color
NC='\033[0m'
HELPERS_LOG_TOPICS=()

INSPECT_GROUPS=$(echo "$INSPECT_GROUPS" | sed 's/^[^[:alpha:]]*//g')
export prefix='\t'
export IN_LOG=0
export IN_CI=1
[ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally
[ $IN_CI -eq 0 ] && prefix=""

# helpers_log_topics=() # Store log headers for pre-exit introspect

test_method() {
  return 20
}

command_log_which() {
  printf "%s\t%s\n" $1 "$(which $1)"
  printf "%s\n" "$2" | sed "s/^.*divider-bin-\([0-9.]*\).*/\1/"
}

before_exit() {
  log BEFORE_EXIT
  printf "%s\n" "${helpers_log_topics[@]}"
  write_result_set $(join_by , ${HELPERS_LOG_TOPICS[@]}) outputs
  log
}

log() {
  [ $IN_LOG -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::"
  IN_LOG=0
  [ -z "$1" ] && return # Input specified we do not need to start a new log group
  echo "::group::$1"
  IN_LOG=1
}

join_by () {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}" | sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
  fi
}

contains() {
  check=$1
  shift
  printf "$prefix%s\n" "$check"
  if [[ $@ =~ "(^|[[:space:]])$check($|[[:space:]])" ]]; then
    return 0
  fi
  return 1
}

# examples:
#   write_result_set $(join_by , ${exampleset[@]})
#   write_result_set $(join_by , ${exampleset[@]}) $LOG_TOPIC
write_result_set() {
  result=$1
  key=$2

  result=$(echo -e "$result" | sed 's/"//g')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"

  HELPERS_LOG_TOPICS+=($KEY)

  [ -z "$key" ] && key="result"
  key=$(echo $key | tr [[:lower:]] [[:upper:]])

  HELPERS_LOG_TOPICS+=($key)

  echo "$key:"
  echo
  printf "\t%s\n" $result
  echo
  echo "::set-output name=$key::$(echo -e $result)"
  echo
}






# . $GITHUB_WORKSPACE/.github/scripts/helpers.sh
# Normalize input inspect_groups
# [ ! -z "$INSPECT_GROUPS" ] && INSPECT_GROUPS=$(printf "%s" "$INSPECT_GROUPS" | sed "s/  */\n/g" | sed '/^$/d' | sed 's/^[^[:space:]]/\t&/')

# printf "%s" "$INSPECT_GROUPS"
# printf "%s" "$INSPECT_GROUPS" | sed 's/^[[:space:]]*//g' | sed '/^$/d'
# exit 0

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

# ESCAPED=$(echo "$ESCAPED" | sed 's/"//g')
# ESCAPED="${ESCAPED//'%'/'%25'}"
# ESCAPED="${ESCAPED//$'\n'/'%0A'}"
# ESCAPED="${ESCAPED//$'\r'/'%0D'}"

# core.addPath	Accessible using environment file GITHUB_PATH
# core.debug	debug
# core.error	error
# core.endGroup	endgroup
# core.exportVariable	Accessible using environment file GITHUB_ENV
# core.getInput	Accessible using environment variable INPUT_{NAME}
# core.getState	Accessible using environment variable STATE_{NAME}
# core.isDebug	Accessible using environment variable RUNNER_DEBUG
# core.saveState	save-state
# core.setFailed	Used as a shortcut for ::error and exit 1
# core.setOutput	set-output
# core.setSecret	add-mask
# core.startGroup	group
# core.warning	warning file

# [ ! -z "$GITHUB_HEAD_REF" ] && HEAD=$GITHUB_HEAD_REF
# [ ! -z "$GITHUB_BASE_REF" ] && BASE=$GITHUB_BASE_REF
# [ ! -z "$GITHUB_REPOSITORY_OWNER" ] && OWNER=$GITHUB_REPOSITORY_OWNER
# [ ! -z "$GITHUB_WORKSPACE" ] && REPO=$GITHUB_WORKSPACE
# GITHUB_API_URL          - https://api.github.com
# GITHUB_AUTH_TOKEN       -
# GITHUB_BASE_REF         - main
# GITHUB_HEAD_REF         - diff_files_Action
# GITHUB_REPOSITORY       - tatehanawalt/homebrew-devtools
# GITHUB_REPOSITORY_OWNER - tatehanawalt
# DEFAULTS

# log() {
#   [ $IN_LOG -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::"
#   IN_LOG=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1"
#   IN_LOG=1
# }
# join_by () {
#   local d=${1-} f=${2-};
#   if shift 2; then
#     printf %s "$f" "${@/#/$d}";
#   fi;
# }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   KEY="RESULT"
#   [ ! -z "$2" ] && KEY="$2"
#   echo "$KEY:"
#   echo $result
#   echo "::set-output name=$KEY::$(echo -e $result)"
# }



# log() {
#   [ $IN_LOG -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::"
#   IN_LOG=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1"
#   IN_LOG=1
# }
# join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   KEY="RESULT"
#   [ ! -z "$2" ] && KEY="$2"
#   echo "$KEY:"
#   echo $result
#   echo
#   echo "::set-output name=$KEY::$(echo -e $result)"
# }


# log() {
#   [ $IN_LOG -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::"
#   IN_LOG=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1"
#   IN_LOG=1
# }
# contains() {
#   check=$1
#   shift
#   [[ $@ =~ (^|[[:space:]])$check($|[[:space:]]) ]] && return 0 || return 1
# }



# for item in ${result[@]}; do printf "%s\n" "$item"; done
# result=$(formula_urls | sed 's/ /,/g')
#formulas=($(formula_names))
#for name in ${formulas[@]}; do
#  printf "%s\n" $name
#  signatures=$(formula_method_signatures $name)
#  for sig in ${signatures[@]}; do
#    formula_method_body $name $sig
#    printf "\n"
#  done
#  printf "\n\n\n"
#done

#dev_parse_formula() {
#  formula_file=$(cat $GITHUB_WORKSPACE/Formula/demozsh.rb)
#  class_name=$(echo "$formula_file" | \
#    grep "class.*" | \
#    sed 's/class[[:space:]]//' | \
#    sed 's/ .*//')
#  header=$(printf "$formula_file" | sed -e '/^$/,$d')
#  header_keys=($(echo "$header" | \
#    sed '/./,$!d' | \
#    grep "[[:alpha:]].*\:" | \
#    sed 's/^[^[:alpha:]]*//g' | \
#    sed 's/ .*//' | \
#    sed 's/:.*//'))
#  header_keys=($(printf "%s\n" ${header_keys[@]} | sort -u))
#  block_lines=$(echo "${formula_file[@]}" | \
#    grep "^  [[:alpha:]]" | \
#    grep -v ".*end.*" | \
#    sed 's/^[^[:alpha:]]*//')
#  block_after_head=$(echo "$block_lines" | sed -n '/head do/,$p' | head -2 | tail -1)
#  echo "$block_after_head"
#  echo "$formula_file"
#  block_after_head="end"
#  echo "$formula_file" | awk '/head do/,/end/'
#  # sed '/^head do$/,/^end$/{//!b};d'
#  # for item in ${header_keys[@]}; do
#  #   printf "\titem: %s\n" $item
#  # done
#  # | sed 's/^# =*//'
#  #  formulas=($(formula_names))
#  #  for item in "${formulas[@]}"; do
#  #    return_set+=("$item:$(formula_url $item)")
#  #  done
#  #  echo "${return_set[@]}"
#}
#exit 0

# echo "$(formula_paths)"
# echo "$(formula_names)"
# echo "$(formula_shas)"
# f_paths=($(formula_paths))
# f_shas=($(formula_shas))
# printf "\tname: %s\n" $name
# for f_path in ${file_paths[@]}; do
#   formula_block_headers "$GITHUB_WORKSPACE/$f_path"
#   echo -e "\n"
# done
# formula_block_headers "$GITHUB_WORKSPACE/Formula/demozsh.rb"

# formula_block_headers() {
#   formula_file=$(cat $1)
#   blocks=($(echo "$formula_file" | grep "^  [[:alpha:]]"))
#   header_blocks=()
#   for ((i=0; i<${#blocks[@]}; i++)); do
#     if  [[ "${blocks[$i]}" =~ "end" ]]; then
#       add_row=${blocks[$((i-1))]}
#       header_blocks+=(${add_row})
#     fi
#   done
#   for block in ${header_blocks[@]}; do
#     printf "%s\n" $block | sed 's/^[[:space:]]*//'
#     echo "$formula_file" | awk "/$block\$/,/^  end/" | sed 1d | sed '$d'
#   done
# }



# log() {
#   [ $IN_LOG -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::"
#   IN_LOG=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1"
#   IN_LOG=1
# }
# join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }
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



# printf "helpers_log_topics\n"
# printf "%s\n" ${helpers_log_topics[@]}
# HEAD is the branch
# BASE is the main
# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# IN_LOG=0
# IN_CI=1
# [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally
# log() {
#   [ $IN_LOG -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::" || echo -e "\n"
#   IN_LOG=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1"
#   IN_LOG=1
# }
# join_by () {
#   local d=${1-} f=${2-};
#   if shift 2; then
#     printf %s "$f" "${@/#/$d}";
#   fi;
# }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   KEY="RESULT"
#   [ ! -z "$2" ] && KEY="$2"
#   echo "$KEY:"
#   echo "$result"
#   echo "::set-output name=$KEY::$(echo -e $result)"
# }


# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# IN_LOG=0
# IN_CI=1
# [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally


# DO NOT MODIFY IFS!
# "
# IN_LOG=0
# IN_CI=1
# IF RUN BY CI vs Locally
# [ "$CI" = "true" ] && IN_CI=0



# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# log() {
#   if [ $IN_LOG -ne 0 ]; then
#     [ $IN_CI -eq 0 ] && echo "::endgroup::";
#     IN_LOG=0
#   fi
#   # Do we need to start a group?
#   if [ ! -z "$1" ]; then
#     [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1:"
#     IN_LOG=1
#   fi
# }


# printf "inc"
# IN_LOG=0
# IN_CI=1
# [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally



# for group in ${groups[@]}; do
  # printf "\t%s\n" "$group"
  # group=$(printf "%s" "$group" | xargs)
  # printf "$prefix%s\n" "$(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]')"
# done

# groups=($(printf "%s" "${INSPECT_GROUPS[@]}" | xargs | tr '[:space:]' '\n'))
# printf "%s\n" ${groups[@]}
# for g in "${groups[@]}"; do
#  printf "g: %s\n\n" "$g"
# done

# groups=$(printf "%s" "$INSPECT_GROUPS" | sed 's/^ \s*//g' | sed '/^$/d' )
# groups=$(printf "%s" "$INSPECT_GROUPS" | tr -s ' ' | sed '/^$/d' )
# groups=($(printf "%s" "$INSPECT_GROUPS" | tr -s ' ' | sed '/^$/d' ))

# Takes a compare branch and outputs the files that have changed between
# the latest compare branch and the commit that fired the action
# TESTING:
# export GITHUB_BASE_REF=<base branch>
# export GITHUB_HEAD_REF=<this branch>
# export GITHUB_WORKSPACE=</path/to/repo>
# IN_LOG=0
# IN_CI=1
# [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# IN_LOG=0
# IN_CI=1
# [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally

# echo $(dirname %0)
# printf "SCRIPTPATH: %s\n\n" "$SCRIPTPATH"
# source $(pwd)/helpers.sh
# printf "%s\n" "$0"
# Used as a debugging script to see what an environment looks like
# source "$GITHUB_WORKSPACE/.github/scripts/helpers.sh"


# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
