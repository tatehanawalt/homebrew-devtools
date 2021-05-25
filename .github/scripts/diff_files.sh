#!/bin/sh
if [ -z "$COMPARE_BRANCH" ]; then
  echo "COMPARE_BRANCH length is 0... set COMPARE_BRANCH=<branch_name>"
  exit 2
fi
if [ -z "$GITHUB_WORKSPACE" ]; then
  echo "GITHUB_WORKSPACE length is 0"
  exit 2
fi
if [ ! -d "$GITHUB_WORKSPACE" ]; then
  echo "GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
  exit 2
fi
echo "COMPARE_BRANCH=$COMPARE_BRANCH"
cd $GITHUB_WORKSPACE
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  git fetch origin "$COMPARE_BRANCH"
  git branch "$COMPARE_BRANCH" FETCH_HEAD
  fetch_exit_code=$?
  echo "FETCH_EXIT_CODE=$fetch_exit_code"
fi
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  echo "FETCH_HEAD for branch $COMPARE_BRANCH"
  exit 2
fi
DIFF_FILES=$(git diff --name-only "$COMPARE_BRANCH")
printf "DIFF_FILES:\n"
printf "\t%s\n" $DIFF_FILES | sort -u
DIFF_DIRS=""
for file_path in $DIFF_FILES; do
  dir=$(dirname $file_path)
  DIFF_DIRS="$DIFF_DIRS $dir\n"
done
DIFF_FILES=$(echo $DIFF_FILES | sed 's/^ //g' | \
  sed 's/  $//g' | \
  sort -u | tr '\n' '  ' | \
  sed 's/^ //g' | \
  sed 's/ $//g' | \
  sed 's/ /,/g')
echo "$DIFF_FILES"
DIFF_DIRS=$(echo $DIFF_DIRS | sed 's/^ //g' | \
  sed 's/  $//g' | \
  sort -u | tr '\n' '  ' | \
  sed 's/^ //g' | \
  sed 's/ $//g' | \
  sed 's/ /,/g')
echo "$DIFF_DIRS"
echo "::set-output name=DIFF_BRANCH::$COMPARE_BRANCH"
echo "::set-output name=DIFF_FILES::$DIFF_FILES"
echo "::set-output name=DIFF_DIRS::$DIFF_DIRS"
exit 0
