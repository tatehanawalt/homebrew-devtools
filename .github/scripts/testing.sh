#!/bin/bash

[ ! -z "$GITHUB_WORKSPACE" ] && \
  SCRIPTPATH="$GITHUB_WORKSPACE/.github/scripts" || \
  SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPTPATH/helpers.sh"

printf "GITHUB_WORKSPACE=$GITHUB_WORKSPACE\n"
printf "pwd: %s\n" $(pwd)
# source "$GITHUB_WORKSPACE/.github/scripts/helpers.sh"


exit 0
