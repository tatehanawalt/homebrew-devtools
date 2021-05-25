#!/bin/sh

# COMPARE_BRANCH=dev
if [ -z "$COMPARE_BRANCH" ]; then
  printf "COMPARE_BRANCH length is 0... set COMPARE_BRANCH=<branch_name>\n" 1>&2;
  exit 2
fi
# Make sure we are in the github workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE length is 0...\n" 1>&2;
  exit 2
fi
if [ ! -d "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE\n" 1>&2;
  exit 2
fi
printf "COMPARE_BRANCH=%s\n" "$COMPARE_BRANCH"
cd $GITHUB_WORKSPACE
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  git fetch origin "$COMPARE_BRANCH" &>/dev/null
  git branch "$COMPARE_BRANCH" FETCH_HEAD &>/dev/null
  fetch_exit_code=$?
  printf "FETCH_EXIT_CODE=$fetch_exit_code\n"
fi
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  printf "\n\nFETCH_HEAD for branch $COMPARE_BRANCH\n" 1>&2;
  exit 2
fi
DIFF_FILES=$(git diff --name-only "$COMPARE_BRANCH")
for f_path in $DIFF_FILES; do
  printf "%s\n" "$f_path"
done
