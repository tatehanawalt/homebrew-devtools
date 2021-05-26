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
echo

formula_paths() {
  file_paths=($(ls $GITHUB_WORKSPACE/Formula/*.rb | tr -s ' ' | tr ' ' '\n'))
  formula_paths=()
  for item in "${file_paths[@]}"; do
    formula_paths+=(${item#$GITHUB_WORKSPACE/});
  done
  echo "${formula_paths[@]}"
}
formula_names() {
  formula_names=()
  file_paths=($(formula_paths))
  for item in "${file_paths[@]}"; do
    formula_names+=($(printf "%s" $item | sed 's/.*\///g' | sed 's/\..*//'));
  done
  echo "${formula_names[@]}"
}
formula_sha() {
  formula_file_path="$GITHUB_WORKSPACE/Formula/$1.rb"
  cat $formula_file_path | \
    awk '/stable/,/sha256.*/' | \
    tail -1 | sed 's/^.[^"]*//' | \
    sed 's/\"//g'
}
formula_shas() {
  formula_shas=()
  formulas=($(formula_names))
  for item in "${formulas[@]}"; do
    formula_shas+=("$item=$(formula_sha $item)")
  done
  echo "${formula_shas[@]}"
}

case $template in
  formula_names)
    result=$(formula_names | sed 's/ /,/g')
    echo -e "formula_names=$result\n"
    echo "::set-output name=RESULT::$result"
    ;;
  formula_paths)
    result=$(formula_paths | sed 's/ /,/g')
    echo -e "formula_paths=$result\n"
    echo "::set-output name=RESULT::$result"
    ;;
  formula_shas)
    result=$(formula_shas | sed 's/ /,/g')
    echo -e "formula_shas=$result\n"
    echo "::set-output name=RESULT::$result"
    ;;
esac

echo
