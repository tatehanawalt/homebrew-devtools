#!/bin/bash

. "$(dirname $0)/helpers.sh"

#  Compare against the main branch
[ -z "$GITHUB_BASE_REF" ] && GITHUB_BASE_REF=main # original ref
[ -z "$GITHUB_HEAD_REF" ] && GITHUB_HEAD_REF=main # current ref

# Using the BASE branch
if [ -z "$GITHUB_BASE_REF" ]; then
  echo "GITHUB_BASE_REF length is 0... set GITHUB_BASE_REF=<branch_name>"
  exit 2
fi

echo "GITHUB_BASE_REF=$GITHUB_BASE_REF"
if [ -z "$GITHUB_WORKSPACE" ]; then
  echo "GITHUB_WORKSPACE length is 0"
  exit 2
fi

if [ ! -d "$GITHUB_WORKSPACE" ]; then
  echo "GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
  exit 2
fi

git fetch origin "$GITHUB_BASE_REF"
git branch "$GITHUB_BASE_REF" FETCH_HEAD

has_diff_branch=$(git branch --list "$GITHUB_BASE_REF")
if [ -z "$has_diff_branch" ]; then
  echo "FETCH_HEAD for branch $GITHUB_BASE_REF"
  exit 2
fi

IFS=$'\n'
diff_files=($(git diff --name-only $GITHUB_BASE_REF | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g'))
diff_files_csv=$(join_by , ${diff_files[@]})

echo "$diff_files_csv"

# write_result_set $(join_by , ${diff_files[@]}) "DIFF_FILES"



# diff_dirs=()
# for file_path in ${diff_files[@]}; do
#   dir=$(dirname $file_path)
#   diff_dirs+=($(dirname $file_path))
# done
# diff_dirs=($(printf "%s\n" ${diff_dirs[@]} | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g' | sort -u))
# write_result_set $(join_by , ${diff_dirs[@]}) "DIFF_DIRS"
# log
# exit 0

# cd $GITHUB_WORKSPACE

# has_diff_branch=$(git branch --list "$GITHUB_BASE_REF")
# if [ -z "$has_diff_branch" ]; then
#   git fetch origin "$GITHUB_BASE_REF"
#   git branch "$GITHUB_BASE_REF" FETCH_HEAD
#   fetch_exit_code=$?
#   echo "FETCH_EXIT_CODE=$fetch_exit_code"
# fi
