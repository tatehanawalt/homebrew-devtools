#!/bin/sh
printf "\n\n"

printf "SH ACTION $0 - ARGS:\n"
printf " - %s\n" "$@"
printf "\n\n"

printf "ENV:\n"
env
# printf " - %s\n"
printf "\n\n"

exit 0
