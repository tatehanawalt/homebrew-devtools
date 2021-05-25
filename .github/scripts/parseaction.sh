#!/bin/sh
printf "\n\n"

printf "SH ONMAIN $0 - ARGS:\n"
if [ ${#@} -gt 0 ]; then
  printf "\t- %s\n" "$@"
  printf "\n"
fi
printf "\n"
printf "ENV:\n"
env | sort
printf "\n\n"

# ENV VARS:
# GITHUB_ACTIONS = Always set to true when GitHub Actions is running the workflow. You can use this variable to differentiate when tests are being run locally or by GitHub Actions.

printf "%-12s%s\n" action "$GITHUB_ACTION"
printf "%-12s%s\n" trigger "$GITHUB_EVENT_NAME"
printf "%-12s%s\n" repo "$GITHUB_WORKSPACE"
printf "%-12s%s\n" commit "$GITHUB_SHA"

if [ ! -z "$GITHUB_HEAD_REF" ] && [ ! -z "$GITHUB_REF" ]; then
  printf "\nPR ACTION\n"
fi

printf "\n\n"



which git
git --no-pager diff --name-only




exit 0
