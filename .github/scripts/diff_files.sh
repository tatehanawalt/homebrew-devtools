#!/bin/sh
if [ -z "$COMPARE_BRANCH" ]; then
  printf "COMPARE_BRANCH length is 0... set COMPARE_BRANCH=<branch_name>\n"
  exit 2
fi
# Make sure we are in the github workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
  printf "GITHUB_WORKSPACE length is 0...\n"
  exit 2
fi
if [ ! -d "$GITHUB_WORKSPACE" ]; then
  printf "GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE\n"
  exit 2
fi
echo
echo "COMPARE_BRANCH=$COMPARE_BRANCH\n"
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
DIFF_DIRS=""
for file_path in $DIFF_FILES; do
  dir=$(dirname $file_path)
  DIFF_DIRS="$DIFF_DIRS $dir\n"
done
echo
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
echo
echo "::set-output name=DIFF_FILES::$(echo $DIFF_FILES | tr ' ' ',')"
echo "::set-output name=DIFF_DIRS::$(echo $DIFF_DIRS | tr ' ' ',')"
echo
exit 0

# for f_path in $DIFF_FILES; do
#   printf "\t%s\n" "$f_path"
# done
