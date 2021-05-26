#!/bin/bash

printf "\n\nLABEL PR\n\n"

printf "ID=%s\n" "$ID"
printf "LABELS=%s\n" "$LABELS"

labels=($(echo -e "${LABELS[@]}" | tr ',' '\n'))

printf "labels:\n"
for label in ${labels[@]}; do
  printf "\t%s\n" "$label"
done
printf "\n"


[ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
[ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
[ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
[ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
[ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
[ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
OWNER="$GITHUB_REPOSITORY_OWNER"
REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')

REQUEST_URL="https://api.github.com/repos/$OWNER/$REPO/issues/$ID/labels"

printf "\nREQUEST_URL=%s\n" "$REQUEST_URL"

curl \
  -X POST \
  -d '["devenv"]' \
  -H "Authorization: token $GITHUB_AUTH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "$REQUEST_URL"


printf "\n"
