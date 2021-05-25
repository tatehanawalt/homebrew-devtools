#!/bin/sh

if [ -z "$COMPARE_BRANCH" ]; then
  printf "COMPARE_BRANCH length is 0... set COMPARE_BRANCH=<branch_name>\n"
  exit 2
fi
# Make sure we are in the github workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE length is 0...\n"
  exit 2
fi
if [ ! -d "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE\n"
  exit 2
fi

printf "COMPARE_BRANCH=%s\n" "$COMPARE_BRANCH"
cd $GITHUB_WORKSPACE

has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  git fetch origin "$COMPARE_BRANCH"
  git branch "$COMPARE_BRANCH" FETCH_HEAD
  fetch_exit_code=$?
  printf "FETCH_EXIT_CODE=$fetch_exit_code\n"
fi

has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  printf "FETCH_HEAD for branch $COMPARE_BRANCH\n"
  exit 2
fi

DIFF_FILES=$(git diff --name-only "$COMPARE_BRANCH")
printf "DIFF_FILES:\n"
printf "\t%s\n" $DIFF_FILES | sort -u

echo "::set-output name=action_fruit::strawberry"

exit 0

# for f_path in $DIFF_FILES; do
#   printf "\t%s\n" "$f_path"
# done
