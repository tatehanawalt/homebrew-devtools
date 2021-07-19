#!/bin/bash

# Introspection generates / parses data related to the contents of the
# specific repository by parsing the local filesystem resources

my_path=$0
. $(dirname $my_path)/helpers.sh

[ -z "$TEMPLATE" ] && [ ! -z "$1" ] && TEMPLATE="$1" && shift
[ -z "$TEMPLATE" ] && write_error "\$TEMPLATE undefined - line $LINENO" && exit 1

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
        for_csv "${kv[1]}" print_field
      done
      for entry in ${groups[@]}; do
        kv=($(echo "$entry" | tr -d '[[:space:]]' | tr '=' '\n'))
        max_field_len=$(csv_max_length ${kv[1]})
        log ${kv[0]}_table
        for_csv "${kv[1]}" print_field_table
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

exec_template $TEMPLATE

before_exit
