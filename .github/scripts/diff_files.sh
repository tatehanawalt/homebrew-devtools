#!/bin/sh
COMPARE_BRANCH=dev

if [ -z "$COMPARE_BRANCH" ]; then
  printf "\$COMPARE_BRANCH length is 0..." 1>&2;
  exit 2
fi

# Make sure we are in the github workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE length is 0..." 1>&2;
  exit 2
fi

if [ ! -d "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE" 1>&2;
  exit 2
fi

printf "\n\nCOMPARE_BRANCH=%s\n\n\n" "$COMPARE_BRANCH"

cd $GITHUB_WORKSPACE
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  git fetch origin $COMPARE_BRANCH
  git branch dev FETCH_HEAD
  fetch_exit_code=$?
  printf "fetch_exit_code=$fetch_exit_code\n"
fi
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  printf "\n\nFETCH_HEAD for branch $COMPARE_BRANCH\n" 1>&2;
  exit 2
fi
diff_files=$(git diff --name-only "$COMPARE_BRANCH")
for f_path in $diff_files; do
  printf "%s\n" "$f_path"
done
