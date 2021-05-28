#!/bin/bash

# IFS=$"\n"
# printf "\nhelpers:\n${@}\nhelpers\n"
max_field_len=0

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

# "\033[38;2;R;G;Bm"
clr=$(printf %b $Red)
nclr=$(printf %b $NC)

HELPERS_LOG_TOPICS=()

IN_LOG=0
IN_CI=1
HAS_TEMPLATE=1

[ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally

# env var template specified
if [ -z "$template" ]; then
  [ ! -z "$1" ] && template="$1"
  if [ ! -z "$template" ]; then
    HAS_TEMPLATE=0
  fi
else
  HAS_TEMPLATE=0
fi


for_csv() {
  IFS=$'\n'
  for field in $(echo $1 | tr ',' '\n'); do
    $2 $field
  done
}

csv_max_length() {
  IFS=$'\n'
  max_field_len=0
  for field in $(printf $1 | tr ',' '\n'); do
    [ ${#field} -gt $max_field_len ] && max_field_len=$((${#field} + 1))
  done
  echo "$max_field_len"
}

join_by () {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}" | sed "s/ $d/$d/g"
    #| sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
    #printf %s "$f" "${@/#/$d}" | sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
  fi
}

contains() {
  check=$1
  shift
  printf "$(get_prefix)%s\n" "$check"
  if [[ $@ =~ "(^|[[:space:]])$check($|[[:space:]])" ]]; then
    return 0
  fi
  return 1
}

get_prefix() {
  printf "\t"
}

command_log_which() {
  printf "%s\t%s\n" $1 "$(which $1)"
  printf "%s\n" "$2" | sed "s/^.*divider-bin-\([0-9.]*\).*/\1/"
}

log() {
  [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally
  if [ $IN_LOG -ne 0 ]; then
    [ $IN_CI -eq 0 ] && echo "::endgroup::"
  fi
  IN_LOG=0
  if [ ! -z "$1" ]; then
    group=$(echo $1 | tr [[:lower:]] [[:upper:]])
    [ $IN_CI -eq 0 ] && echo "::group::$group"
    [ $IN_CI -eq 1 ] && printf "${Blue}$group:${NC}\n"
    IN_LOG=1
  fi
  return 0
}

log_result_set() {
  printf "$(get_prefix)%s\n" $(echo -e $1 | tr ',' '\n')
}
write_result_set() {
  IFS=$'\n'
  result=$(echo -e "$1" | sed 's/"//g')
  [ -z "$result" ] && return 1
  key=$2
  [ -z "$key" ] && key="result"
  key=$(echo $key | tr [[:lower:]] [[:upper:]])
  log $key
  log_result_set "$result" "$key"
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  printf "$key='$result'\n"
  [ $IN_CI -eq 0 ] && echo "::set-output name=$key::$(echo -e $result)"
  HELPERS_LOG_TOPICS+=($key)
}

write_result_map() {
  IFS=$'\n'
  result=$(echo -e "$1" | sed 's/"//g')
  [ -z "$result" ] && return 1
  key=$2
  [ -z "$key" ] && key="result"
  key=$(echo $key | tr [[:lower:]] [[:upper:]])
  log $key
  log_result_set "$result" "$key"
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  printf "$key='$result'\n"
  [ $IN_CI -eq 0 ] && echo "::set-output name=$key::$3=$(echo -e $result)"
  HELPERS_LOG_TOPICS+=($key)
}

print_field() {
  printf "%s=$(eval "echo \"\$$1\"")\n" $1
}

print_field_table() {
  IFS=$'\n'
  field_val=$(eval "echo \"\$$1\"" | tr ',' '\n' | sed 's/^[[:space:]]*//g' | sed '/^$/d' | sed 's/=/=\n/')
  field_val=($(echo "$field_val"))
  local_prefix=""
  printf "\t%-${max_field_len}s" "$1:"
  [ -z "$field_val" ] && echo && return

  [ ${#field_val[@]} -gt 1 ] && echo && local_prefix="$(get_prefix)   - "

  # printf "$local_prefix%s\n" ${field_val[@]};
  for field in "${field_val[@]}"; do
    lbl_clr=''
    if [[ "$field" =~ .*\=.* ]]; then
      lbl_clr=$Yellow
      field=$(echo $field | tr [[:lower:]] [[:upper:]] | sed "s/^/$clr/" | sed "s/=/=$nclr/" )

      # field=$(echo $field | sed "s/\=/$( printf %b ${NC} )\=/ )")

      # field=$(echo $field | sed s/$/$(printf %b $NC)$/)
    fi
    printf "$local_prefix%s\n" $field
  done

  # printf "$local_prefix%s\n" ${field_val[@]};
}

before_exit() {
  [ -z "$HELPERS_LOG_TOPICS" ] && return
  write_result_set "$(join_by , ${HELPERS_LOG_TOPICS[@]})" outputs
  log
}



# log $key
# printf "$key=$result\n"
# helpers_log_topics=() # Store log headers for pre-exit introspect
# [ $IN_CI -eq 0 ] && prefix=""
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

# key=$1
# [ -z "$key" ] && key="result"
# result=$(echo -e "$2" | sed 's/"//g')
# result="${result//'%'/'%25'}"
# result="${result//$'\n'/'%0A'}"
# result="${result//$'\r'/'%0D'}"


# echo "CI=$IN_CI"
# echo "OWNER=$OWNER"
# echo "NAME=$NAME"
# echo "REPO=$REPO"
# echo "HEAD=$HEAD"
# echo "BASE=$BASE"
# echo "USER=$USER"
# echo "TAG=$TAG"
# echo "ID=$ID"
# echo "template=$template"

# echo "QUERY_BASE=$QUERY_BASE"
# echo "TOPIC=$TOPIC"
# echo "WITH_SEARCH=$WITH_SEARCH"
# echo "WITH_AUTH=$WITH_AUTH"
# echo "WITH_DELETE=$WITH_DELETE"
# echo "QUERY_URL=$QUERY_URL"
# echo "SEARCH_FIELD=$SEARCH_FIELD"
# echo "SEARCH_STRING=$SEARCH_STRING"
# echo "ID=$ID"

# if [ -z "$template" ]; then
#   [ ! -z "$1" ] && template="$1"
#   if [ -z "$template" ]; then
#     echo "NO TEMPLATE SPECIFIED"
#     exit 1
#   fi
# fi


# log() {
#   [ $in_log -ne 0 ] && [ $IN_CI -eq 0 ] && echo "::endgroup::"
#   in_log=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $IN_CI -eq 0 ] && echo "::group::$1" || echo "$1"
#   in_log=1
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
# contains() {
#   check=$1
#   shift
#   printf "\t%s\n" "$check"
#   [[ $@ =~ (^|[[:space:]])$check($|[[:space:]]) ]] && return 0 || return 1
# }
# DIFF_FORMULA=demozsh,devenv
