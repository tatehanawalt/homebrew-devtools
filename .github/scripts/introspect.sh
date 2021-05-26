#!/bin/bash

# Returns values about a repo specific to our repo implementation

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

formula_paths() {
  file_paths=$(ls $GITHUB_WORKSPACE/Formula/*.rb)
  formula_paths=()
  for f_path in $file_paths; do formula_paths+=(${f_path#$GITHUB_WORKSPACE/}); done

  #echo "${formula_paths[@]}" | sed 's/ /,/g'
  echo "${formula_paths[@]}"
}

echo
case $template in
  formula_paths)
    # file_paths=$(ls $GITHUB_WORKSPACE/Formula/*.rb)
    # formula_paths=()
    # for f_path in $file_paths; do formula_paths+=(${f_path#$GITHUB_WORKSPACE/}); done
    item_set=$(formula_paths | sed 's/ /,/g')
    echo "formula_paths=$item_set"
    echo "::set-output name=RESULT::$item_set"
    ;;
  formula_names)
    formulas=()
    item_set=$(formula_paths)
    for item in $item_set; do
      formulas+=($(printf "%s\n" $item | sed 's/.*\///g' | sed 's/\..*//'));
    done
    formulas=$(echo "${formulas[@]}" | sed 's/ /,/g')
    echo "formula_names=$formulas"
    echo "::set-output name=RESULT::$formulas"
    ;;
esac
echo
