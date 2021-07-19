#!/bin/bash

my_path=$0
. $(dirname $my_path)/helpers.sh

# Introspection generates / parses data related to the contents of the
# specific repository by parsing the local filesystem resources

function formula_path() {
  [ ! -d "$FORMULA_DIR" ] && printf "FORMULA_DIR not a directory\n" && exit 1
  [ ! -f "$FORMULA_DIR/$1.rb" ] && return 1
  printf "$FORMULA_DIR/$1.rb"
}
function formula_file() {
  formula_path=$(formula_path $1)
  [ $? -ne 0 ] && printf "$1 formula path not found\n" && return 1
  cat $formula_path
}
function formula_method_signatures() {
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
function formula_method_body() {
  IFS=$'\n'
  slim_file=$(formula_file $1 | sed '/#.*/d')
  sub_slim_file=$(echo "$slim_file" | \
    sed 's/.*".*//' | \
    sed "s/.*'.*//" | \
    sed '/^$/d')
  echo "$sub_slim_file"
  # Standard padding for a method signature
  signatures_prefix=$(echo "$sub_slim_file" | head -n 2 | tail -n 1 | sed 's/[[:alnum:]].*//')
  # printf "|%s|\n\n" $signatures_prefix
  echo "$slim_file" | awk "/$2/,/^${signatures_prefix}end/"
}
function formula_sha() {
  formula_method_body $1 $2 | \
    grep "sha256.*" | \
    tr \' \" | \
    cut -d '"' -f 2
}
function formula_url() {
  IFS=$'\n'
  formula_method_body "$1" "$2" | \
    grep 'url.*' | \
    tr \' \" | \
    cut -d '"' -f 2
}
function formula_names() {
  find "$FORMULA_DIR" \
    -maxdepth 1 \
    -type f \
    -name '*.rb' \
    -exec basename {} \; | \
    sed 's/\..*//' | \
    sort -u
}
function formula_paths() {
  for item in $(formula_names); do
    val=$(formula_path $item)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_stable_shas() {
  for item in $(formula_names); do
    val=$(formula_sha $item stable)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_head_shas() {
  for item in $(formula_names); do
    val=$(formula_sha $item head)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_head_urls() {
  for item in $(formula_names); do
    val=$(formula_url "$item" "head")
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_stable_urls() {
  for item in $(formula_names); do
    val=$(formula_url "$item" "stable")
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_signatures() {
  IFS=$'\n'
  for item in $(formula_names); do
    printf "%s\n" $item
    formula_method_signatures $item
  done
}
function testfn() {
  IFS=$'\n'
  printf "${Red}%s\n" $(echo "$1" | tr [[:lower:]] [[:upper:]])
  data=$($1)
  printf "$(get_prefix)%s\n" $data
  printf "${Red}%s\n" $(echo "${1}_CSV" | tr [[:lower:]] [[:upper:]])
  data_lcsv=$(join_by , $data)
  printf "$(get_prefix)%s\n" $data_lcsv
  printf "${NC}"
  [ ! -z "$data_lcsv" ] && echo
}
function test_all() {
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
function all() {
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
    IFS=$'\n'
    write_result_set "$(join_by , $($method))" $method
  done
}

function exec_template() {
  case $1 in
    all)
      all
      ;;
    formula*)
      write_result_set "$(join_by , $($1))" $1
      ;;
    show_env)
      # IFS=$'\n'
      env_csv=$(join_by , $(env | grep -o '^[^[:space:]].*' | sed 's/=.*//' | sort))
      INSPECT_GROUPS=$(echo "$INSPECT_GROUPS" | tr ' ' '\n' | sed 's/^[[:space:]]*//' | sed '/^$/d')
      groups=($(printf "${INSPECT_GROUPS[@]}\nenv=$env_csv" | tr ' ' '\n' | sort))
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
      write_error "$(basename $0) template $template not recognized - line $LINENO"
      exit 1
      ;;
  esac
}


[ -z "$FORMULA_DIR" ] && FORMULA_DIR="$GITHUB_WORKSPACE/Formula"
[ -z "$TEMPLATE" ] && [ ! -z "$1" ] && TEMPLATE="$1" && shift
[ -z "$TEMPLATE" ] && write_error "\$TEMPLATE undefined" && exit 1

exec_template $TEMPLATE


# write_result_set $result RESULT




before_exit
exit 0

# my_path="$GITHUB_WORKSPACE/.github/scripts/git_api.sh"
# if [ "$CI" != "true" ]; then
#   my_path=$(readlink $0)
# fi
# [ $HAS_TEMPLATE -ne 0 ] && echo "NO TEMPLATE SPECIFIED" && exit 1
# IFS=$'\n'
