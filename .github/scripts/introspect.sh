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
echo "template=$template"
echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
echo
log

formula_method_signatures() {
  formula_path="$GITHUB_WORKSPACE/Formula/$1.rb"
  formula_file=$(cat $formula_path)
  blocks=($(echo "$formula_file" | grep "^  [[:alpha:]].*"))
  header_blocks=()
  for ((i=0; i<${#blocks[@]}; i++)); do
    if  [[ "${blocks[$i]}" =~ ^[[:space:]]+end ]]; then
      header_blocks+=(${blocks[$(($i - 1))]})
    fi
  done
  printf "%s\n" ${header_blocks[@]}
}
formula_method_body() {
  formula_path="$GITHUB_WORKSPACE/Formula/$1.rb"
  formula_file=$(cat $formula_path)
  printf "%s\n" "$formula_file" | awk "/$2/,/^[[:space:]][[:space:]]end/"
}

formula_paths() {
  return_set=()
  file_paths=($(ls $GITHUB_WORKSPACE/Formula/*.rb | tr -s ' ' | tr ' ' '\n'))
  for item in "${file_paths[@]}"; do
    formula=$(echo "${item#$GITHUB_WORKSPACE/Formula/}" | sed 's/\..*//')
    return_set+=("$formula\t${item#$GITHUB_WORKSPACE/}");
  done
  printf "%s\n" ${return_set[@]}
}
formula_names() {
  return_set=()
  file_paths=($(formula_paths))
  for item in "${file_paths[@]}"; do
    return_set+=($(printf "%s" $item | sed 's/.*\///g' | sed 's/\..*//'));
  done
  printf "%s\n" "${return_set[@]}"
}

formula_sha() {
  formula_file_path="$GITHUB_WORKSPACE/Formula/$1.rb"
  cat $formula_file_path | \
    awk '/stable/,/sha256.*/' | \
    tail -1 | sed 's/^.[^"]*//' | \
    sed 's/\"//g'
}
formula_shas() {
  return_set=()
  formulas=($(formula_names))
  for item in "${formulas[@]}"; do
    return_set+=("$item\t$(formula_sha $item)")
  done
  printf "%s\n" ${return_set[@]}
}
formula_shas2() {
  return_set=()
  formulas=($(formula_names))
  for item in "${formulas[@]}"; do
    shaval=$(formula_sha $item)
    # kvset=$(printf "%s\t%s\n" $item $shaval)
    # return_set+=($(printf "$item\t%s" $shaval))
    # # return_set+=("$item\t$(formula_sha $item)")
    printf "$item\t%s\n" $shaval
  done
  # printf "%s\n" ${return_set[@]}
}


formula_url() {
  formula_method_body $1 $2 | \
    grep 'url.*' | \
    sed "s/\'/\"/g" | \
    cut -d '"' -f 2
}
formula_urls() {
  return_set=()
  formulas=($(formula_names))
  for item in ${formulas[@]}; do
    url="$(formula_url $item $1)"
    return_set+=("$item\t${url}")
  done
  printf "%s\n" ${return_set[@]}
}



# IFS='\n'

test_var=("$(formula_shas2 | sed 's/[^[:alnum:]]$//g' | tr '\n' ',')")


printf "%s\n" "$test_var" | cat -et
# printf "%s\n" "$test_var" | cat -et


# echo
#echo
# echo "$(join_by , ${test_var[@]})"



# echo "$test_var" | cat -v
# formula_names
# formula_shas2

exit 0

# strset=$(formula_shas)
# printf "1.\n%s\n" "$strset"
# printf "\n\n"
# printf "2.\n%s\n" "${strset[@]}"
# printf "\n\n"
# write_result_set $(join_by , "$(formula_shas)")

exit 0




case $template in
  formula_names)
    write_result_set $(join_by , $(formula_names))
    ;;
  formula_paths)
    write_result_set $(join_by , $(formula_paths))
    ;;
  formula_shas)
    write_result_set $(join_by , "$(formula_shas)")
    ;;
  formula_stable_urls)
    write_result_set $(join_by , $(formula_urls stable))
    ;;
  formula_head_urls)
    write_result_set $(join_by , $(formula_urls head))
    ;;
esac

exit 0
