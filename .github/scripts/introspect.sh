#!/bin/sh

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

echo "template=$template"
echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"


# case $template in
#   formula)
#     ;;
# esac
