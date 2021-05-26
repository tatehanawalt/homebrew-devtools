#!/bin/bash
# Takes a compare branch and outputs the files that have changed between
# the latest compare branch and the commit that fired the action
# TESTING:
# export GITHUB_BASE_REF=<base branch>
# export GITHUB_HEAD_REF=<this branch>
# export GITHUB_WORKSPACE=</path/to/repo>
#
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
join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }
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
#  Compare against the main branch
[ -z "$GITHUB_BASE_REF" ] && GITHUB_BASE_REF=main
[ -z "$GITHUB_HEAD_REF" ] && GITHUB_HEAD_REF=main
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
cd $GITHUB_WORKSPACE
export has_diff_branch=$(git branch --list "$GITHUB_BASE_REF")
if [ -z "$has_diff_branch" ]; then
  git fetch origin "$GITHUB_BASE_REF"
  git branch "$GITHUB_BASE_REF" FETCH_HEAD
  fetch_exit_code=$?
  echo "FETCH_EXIT_CODE=$fetch_exit_code"
fi
has_diff_branch=$(git branch --list "$GITHUB_BASE_REF")
if [ -z "$has_diff_branch" ]; then
  echo "FETCH_HEAD for branch $GITHUB_BASE_REF"
  exit 2
fi
diff_files=($(git diff --name-only $GITHUB_BASE_REF | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g'))
write_result_set $(join_by , ${diff_files[@]}) "DIFF_FILES"
diff_dirs=()
for file_path in ${diff_files[@]}; do
  dir=$(dirname $file_path)
  diff_dirs+=($(dirname $file_path))
done
diff_dirs=($(printf "%s\n" ${diff_dirs[@]} | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g' | sort -u))
write_result_set $(join_by , ${diff_dirs[@]}) "DIFF_DIRS"
exit 0
