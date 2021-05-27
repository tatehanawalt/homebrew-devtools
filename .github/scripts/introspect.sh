#!/bin/bash

. "$GITHUB_WORKSPACE/.github/scripts/helpers.sh"

# Introspection generates / parses data related to the contents of the
# specific repository by parsing the local filesystem resources
#
#
# IF any results require curl or any other network requests they should not
# be part of this file

# Returns values about a repo specific to our repo implementation
# TEST VALUES:
[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
if [ -z "$template" ]; then
  [ ! -z "$1" ] && template="$1"
  if [ -z "$template" ]; then
    echo "NO TEMPLATE SPECIFIED"
    exit 1
  fi
fi

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
in_log=0
IN_CI=1
[ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally

log PARAMS
FORMULA_DIR="$GITHUB_WORKSPACE/Formula"
echo "template=$template"
echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
echo "FORMULA_DIR=$FORMULA_DIR"
log
[ ! -d "$FORMULA_DIR" ] && printf "FORMULA_DIR not a directory\n" && exit 1

formula_path() {
  [ ! -d $FORMULA_DIR ] && return 1
  [ ! -f "$FORMULA_DIR/$1.rb" ] && return 1
  printf "$FORMULA_DIR/$1.rb"
  return 0
}
formula_file() {
  formula_path=$(formula_path $1)
  [ $? -ne 0 ] && printf "$1 formula path not found\n" && return 1
  cat $formula_path
  return 0
}
formula_method_signatures() {
  file_body=$(formula_file $1)
  [ $? -ne 0 ] && printf $file_body && return 1
  blocks=($(echo $file_body | grep "^  [[:alpha:]].*"))
  header_blocks=()
  for ((i=0; i<${#blocks[@]}; i++)); do
    if  [[ "${blocks[$i]}" =~ ^[[:space:]]+end ]]; then
      header_blocks+=(${blocks[$(($i - 1))]})
    fi
  done
  printf "%s\n" ${header_blocks[@]}
}
formula_method_body() {
  file_body=$(formula_file $1)
  [ $? -ne 0 ] && printf "$file_body" && return 1
  printf "%s\n" $file_body | awk "/$2/,/^[[:space:]][[:space:]]end/"
}
formula_sha() {
  formula_method_body $1 $2 | \
    grep "sha256.*" | \
    tr \' \" |
    sed 's/.*"\(.*\)".*/\1/'
}
formula_url() {
  formula_method_body $1 $2 | \
    grep 'url.*' | \
    sed "s/\'/\"/g" | \
    cut -d '"' -f 2
}

formula_names() {
  formulas=($(find $FORMULA_DIR -maxdepth 1 -type f -name "*.rb" | sort))
  for item in ${formulas[@]}; do
    printf "%s$IFS" $(basename ${item%%.*})
  done
}
formula_paths() {
  for item in $(formula_names); do
    printf "%s %s$IFS" $item $(formula_path $item)
  done
}
formula_stable_shas() {
  for item in $(formula_names); do
    printf "%s %s$IFS" $item $(formula_sha $item stable)
  done
}
formula_head_shas() {
  for item in $(formula_names); do
    printf "%s %s$IFS" $item $(formula_sha $item head)
  done
}
formula_head_urls() {
  for item in $(formula_names); do
    printf "%s %s$IFS" $item $(formula_url $item head)
  done
}
formula_stable_urls() {
  for item in $(formula_names); do
    printf "%s %s$IFS" $item $(formula_url $item stable)
  done
}

testfn() {
  printf "${Red}%s${Cyan}\n" $(echo "$1" | tr [[:lower:]] [[:upper:]])
  printf "\t%s\n" $($1)
  printf "${Red}%s${Cyan}\n" $(echo "$1_CSV" | tr [[:lower:]] [[:upper:]])
  printf "\t%s\n" $(join_by , $($1))
  printf "${NC}\n"
}

test_all() {
  echo
  testfn formula_names
  testfn formula_paths
  testfn formula_stable_shas
  testfn formula_head_shas
  testfn formula_stable_urls
  testfn formula_head_urls
  echo
}

all() {
  log all
  call_fns=(
    formula_names
    formula_paths
    formula_stable_shas
    formula_head_shas
    formula_stable_urls
    formula_head_urls
  )
  write_result_set $(join_by , ${call_fns[@]}) functions

  for method in ${call_fns[@]}; do
    log $method
    write_result_set $(join_by , $($method)) $method
  done
  before_exit
}

IFS=$'\n'
case $template in
  all)
    all
    ;;
  formula*)
    write_result_set $(join_by , $($1)) $1
    ;;
  test)
    test_all
    ;;
  *)
    printf "UNHANDLED TARGET: $1"
    exit 1
    ;;
esac
exit 0

# formula_names)
#   # write_result_set $(join_by , $(formula_names)) formula_names
#   ;;
# formula_paths)
#   # write_result_set $(join_by , $(formula_paths))
#   ;;
# formula_stable_shas)
#   # write_result_set $(join_by , $(formula_stable_shas))
#   ;;
# formula_head_shas)
#   # write_result_set $(join_by , $(formula_head_shas))
#   ;;
# formula_stable_urls)
#   # write_result_set $(join_by , $(formula_stable_urls))
#   ;;
# formula_head_urls)
#   # write_result_set $(join_by , $(formula_head_urls))
#   ;;
