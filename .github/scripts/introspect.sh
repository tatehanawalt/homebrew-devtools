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
  printf "%s" $file_body | awk "/$2/,/^[[:space:]][[:space:]]end/"
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
  for item in $(formula_names); do
    val=$(formula_path $item)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
formula_stable_shas() {
  for item in $(formula_names); do
    val=$(formula_sha $item stable)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
formula_head_shas() {
  for item in $(formula_names); do
    val=$(formula_sha $item head)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
formula_head_urls() {
  for item in $(formula_names); do
    val=$(formula_url "$item" "head")
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
formula_stable_urls() {
  for item in $(formula_names); do
    val=$(formula_url "$item" "stable")
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
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
  # test_all
  # log_result_set "$(join_by , ${call_fns[@]})" call_fns "FORMULA_FUNCTIONS"
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
  show_env)
    env_csv=$(join_by , $(env | grep -o '^[^[:space:]].*' | sed 's/=.*//' | sort))
    groups=($(printf "$INSPECT_GROUPS\nenv=$env_csv\n"| sed 's/^[[:space:]]*//' | sed '/^$/d' | sort))

    write_result_set "$(join_by , $(printf "%s\n" ${groups[@]} | sed 's/=.*//'))" inspect_groups

    for entry in ${groups[@]}; do
      kv=($(echo "$entry" | tr -d '[[:space:]]' | tr '=' '\n'))
      log ${kv[0]}
      for_csv ${kv[1]} print_field
    done

    for entry in ${groups[@]}; do
      kv=($(echo "$entry" | tr -d '[[:space:]]' | tr '=' '\n'))
      max_field_len=$(csv_max_length ${kv[1]})
      log ${kv[0]}_table
      for_csv ${kv[1]} print_field_table
    done
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
