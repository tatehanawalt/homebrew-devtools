#!/bin/sh

# Used as a debugging script to see what an environment looks like

ENV_MAP=$(env)

echo "::group::env"
printf "ENV:\n"
printf "\t%s\n" $ENV_MAP | sort -u
echo "::endgroup::"

echo "::group::env-traverse"
for entry in $ENV_MAP; do
  printf "%s" "$entry"
done
echo "::endgroup::"


printf "LABELS: %s\n" "$LABELS"
printf "LABELS: %s\n" "${LABELS}"
