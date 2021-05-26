#!/bin/bash

# Returns values about a repo specific to our repo implementation
# TEST VALUES:

FORMULA=demogolang

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
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally
log() {
  [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
  in_log=0
  [ -z "$1" ] && return # Input specified we do not need to start a new log group
  [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
  in_log=1
}

# log PARAMS
echo "template=$template"
echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"

function join_by { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }

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
    return_set+=(${item#$GITHUB_WORKSPACE/});
  done
  printf "%s\n" ${return_set[@]}
}
formula_names() {
  return_set=()
  file_paths=($(formula_paths))
  for item in ${file_paths[@]}; do
    return_set+=($(printf "%s" $item | sed 's/.*\///g' | sed 's/\..*//'));
  done
  printf "%s\n" ${return_set[@]}

  # echo "${return_set[@]}"
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
  for item in ${formulas[@]}; do
    return_set+=("$item\t$(formula_sha $item)")
  done
  printf "%s\n" ${return_set[@]}
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
  printf "%s\n" "${return_set[@]}"
}

case $template in
  formula_names)
    echo "::set-output name=RESULT::$(join_by , $(formula_names))"
    ;;
  formula_paths)
    echo "::set-output name=RESULT::$(join_by , $(formula_paths))"
    ;;
  formula_shas)
    echo "::set-output name=RESULT::$(join_by , $(formula_shas))"
    ;;
  formula_stable_urls)
    result="$(join_by , $(formula_urls stable))"

    result=$(echo -e "$result" | sed 's/"//g')
    result="${result//'%'/'%25'}"
    result="${result//$'\n'/'%0A'}"
    result="${result//$'\r'/'%0D'}"

    echo
    # echo -e $result
    echo $result
    echo
    echo "::set-output name=RESULT::$(echo -e $result)"
    ;;
  formula_head_urls)
    result="$(join_by , $(formula_urls head))"

    result=$(echo -e "$result" | sed 's/"//g')
    result="${result//'%'/'%25'}"
    result="${result//$'\n'/'%0A'}"
    result="${result//$'\r'/'%0D'}"

    echo
    # echo -e $result
    echo $result
    echo
    echo "::set-output name=RESULT::$(echo $result)"
    # echo "::set-output name=RESULT::$(echo -e $result)"
    ;;
esac

echo
exit 0



# result=($(printf "%s\n" $(formula_urls)))
# result=$(echo "${result[@]}" | tr '\n' '\t')
#  echo -e "formula_urls=$result\n"
# echo "::set-output name=RESULT::$result"

# result=$(formula_paths | sed 's/ /,/g')
# echo -e "formula_paths=$result\n"
# echo "::set-output name=RESULT::$result"

# result=$(formula_names | tr '\n' ' ' | sed 's/ /,/g')
# result=($(formula_names))
# printf "%s" $(join_by , "${result[@]}")
# printf "%s" $(join_by , $(formula_names))
# echo "${result[@]}" | sed 's/\n/,/g'
# echo $result | sed 's/ /,/g'
# echo -e "formula_names=$result\n"



# IFS="\t"
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
