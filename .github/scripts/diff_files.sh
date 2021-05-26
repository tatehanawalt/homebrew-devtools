#!/bin/sh

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
join_by () {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}";
  fi;
}
write_result_set() {
  result="$1"
  result=$(echo -e "$result" | sed 's/"//g')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  KEY="RESULT"
  [ ! -z "$2" ] && KEY="$2"
  echo "$KEY:"
  echo $result
  echo
  echo "::set-output name=$KEY::$(echo -e $result)"
}

# Takes a compare branch and outputs the files that have changed between
# the latest compare branch and the commit that fired the action

#  Compare against the main branch
[ -z "$GITHUB_BASE_REF" ] && GITHUB_BASE_REF=main

# Using the HEAD branch
[ -z "$GITHUB_HEAD_REF" ] && GITHUB_HEAD_REF=main
if [ -z "$GITHUB_HEAD_REF" ]; then
  echo "GITHUB_HEAD_REF length is 0... set GITHUB_HEAD_REF=<branch_name>"
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

echo "GITHUB_HEAD_REF=$BASE"
cd $GITHUB_WORKSPACE
has_dif_branch=$(git branch --list "$GITHUB_BASE_REF")
if [ -z "$has_dif_branch" ]; then
  git fetch origin "$GITHUB_BASE_REF"
  git branch "$GITHUB_BASE_REF" FETCH_HEAD
  fetch_exit_code=$?
  echo "FETCH_EXIT_CODE=$fetch_exit_code"
fi
has_dif_branch=$(git branch --list "$GITHUB_BASE_REF")
if [ -z "$has_dif_branch" ]; then
  echo "FETCH_HEAD for branch $GITHUB_BASE_REF"
  exit 2
fi



DIFF_FILES=$(git diff --name-only "$GITHUB_BASE_REF")
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
echo "::set-output name=DIFF_BRANCH::$GITHUB_HEAD_REF"
echo "::set-output name=DIFF_FILES::$DIFF_FILES"
echo "::set-output name=DIFF_DIRS::$DIFF_DIRS"
exit 0
