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


# curl \
#   -X POST \
#   -H "Accept: application/vnd.github.v3+json" \
#   https://api.github.com/repos/octocat/hello-world/issues/42/labels


printf "\n"
