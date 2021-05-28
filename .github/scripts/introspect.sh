#!/bin/bash

. "$(dirname $0)/helpers.sh" ${@}

# Introspection generates / parses data related to the contents of the
# specific repository by parsing the local filesystem resources
#
#
# IF any results require curl or any other network requests they should not
# be part of this file

# Returns values about a repo specific to our repo implementation
# TEST VALUES:

# [ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
FORMULA_DIR="$GITHUB_WORKSPACE/Formula"
[ $HAS_TEMPLATE -ne 0 ] && echo "NO TEMPLATE SPECIFIED" && exit 1

log_result_set "template=$template,GITHUB_WORKSPACE=$GITHUB_WORKSPACE,FORMULA_DIR=$FORMULA_DIR" PARAMS

[ ! -d "$FORMULA_DIR" ] && printf "FORMULA_DIR not a directory\n" && exit 1

formula_path() {
  IFS=$'\n'
  [ ! -d $FORMULA_DIR ] && return 1
  [ ! -f "$FORMULA_DIR/$1.rb" ] && return 1
  printf "$FORMULA_DIR/$1.rb"
}
formula_file() {
  IFS=$'\n'
  formula_path=$(formula_path $1)
  [ $? -ne 0 ] && printf "$1 formula path not found\n" && return 1
  cat $formula_path
}
formula_method_signatures() {
  IFS=$'\n'
  slim_file=$(formula_file $1 | \
    sed 's/#.*//' | \
    grep -o '.*[[:alnum:]].*' | \
    sed 's/.*".*//' | \
    sed "s/.*'.*//" | \
    sed '/^$/d')
  signatures_prefix=$(printf "${slim_file}\n" | head -n 2 | tail -n 1 | sed 's/[[:alnum:]].*//')
  file_body=$(printf "$slim_file" | grep "^$signatures_prefix[^ ].*")
  prev=""
  for row in $file_body; do
    [[ "$row" =~ ^[[:space:]]+end ]] && printf "%s\n" "$prev"
    prev=$row
  done
}
formula_method_body() {
  IFS=$'\n'
  file_body=$(formula_file $1)
  [ $? -ne 0 ] && printf "$file_body" && return 1
  printf "%s\n" $file_body | awk "/$2/,/^[[:space:]][[:space:]]end/"
}
formula_sha() {
  IFS=$'\n'
  formula_method_body "$1" "$2" | \
    grep "sha256.*" | \
    tr \' \" | \
    cut -d '"' -f 2
}
formula_url() {
  IFS=$'\n'
  formula_method_body "$1" "$2" | \
    grep 'url.*' | \
    tr \' \" | \
    cut -d '"' -f 2
}
formula_names() {
  find "$FORMULA_DIR" \
    -maxdepth 1 \
    -type f \
    -name '*.rb' \
    -exec basename {} \; | \
    sed 's/\..*//' | \
    sort -u
}
formula_paths() {
  IFS=$'\n'
  for item in $(formula_names); do
    val=$(formula_path $item)
    [ -z "$val" ] && continue
    printf "$item $val$IFS"
  done
}
formula_stable_shas() {
  IFS=$'\n'
  for item in $(formula_names); do
    val=$(formula_sha $item stable)
    [ -z "$val" ] && continue
    printf "$item $val$IFS"
  done
}
formula_head_shas() {
  IFS=$'\n'
  for item in $(formula_names); do
    val=$(formula_sha $item head)
    [ -z "$val" ] && continue
    printf "%s %s$IFS" "$item" "$val"
  done
}
formula_head_urls() {
  IFS=$'\n'
  for item in $(formula_names); do
    val=$(formula_url "$item" "head")
    [ -z "$val" ] && continue
    printf "$item $val$IFS"
  done
}
formula_stable_urls() {
  IFS=$'\n'
  for item in $(formula_names); do
    val=$(formula_url "$item" "stable")
    [ -z "$val" ] && continue
    printf "$item $val$IFS"
  done
}
formula_signatures() {
  IFS=$'\n'
  for item in $(formula_names); do
    printf "%s\n" $item
    formula_method_signatures $item
  done
}

testfn() {
  IFS=$'\n'
  printf "${Red}%s${Cyan}\n" $(echo "$1" | tr [[:lower:]] [[:upper:]])
  data=$($1)
  printf "${Cyan}$(get_prefix)%s\n" $data
  printf "${Red}%s\n" $(echo "${1}_CSV" | tr [[:lower:]] [[:upper:]])
  data_lcsv=$(join_by , $data)
  printf "${Cyan}$(get_prefix)%s\n" $data_lcsv
  printf "${NC}"

  [ ! -z "$data_lcsv" ] && echo
}

test_all() {
  IFS=$'\n'
  testfn formula_names
  testfn formula_paths
  testfn formula_stable_shas
  testfn formula_head_shas
  testfn formula_stable_urls
  testfn formula_head_urls
  for item in $(formula_names); do
    echo "$item"
    formula_method_signatures "$item"
  done
}

all() {
  IFS=$'\n'
  call_fns=(
    formula_names
    formula_paths
    formula_stable_shas
    formula_head_shas
    formula_stable_urls
    formula_head_urls
    formula_method_signatures
  )
  test_all
  log_result_set "$(join_by , ${call_fns[@]})" functions "FORMULA_FUNCTIONS"
  for method in ${call_fns[@]}; do
    write_result_set "$(join_by , $($method))" $method
  done
}

case $template in
  all)
    all
    ;;
  formula_signatures)
    formula_signatures
    ;;
  formula*)
    write_result_set "$(join_by , $($1))" $1
    ;;
  test)
    test_all
    ;;
  *)
    printf "UNHANDLED TARGET: $1"
    exit 1
    ;;
esac

before_exit

exit 0

# formulas=($(find $FORMULA_DIR -maxdepth 1 -type f -name '*.rb' | sort))
# names=()
# printf "\n\n${#formulas[@]}\n"
# for item in ${formulas[@]}; do
  # names+=("$(basename ${item%%.*})")
# done
# printf "%s\n" ${names[@]} | sort
