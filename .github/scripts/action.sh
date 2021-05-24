#!/bin/sh
printf "\n\n"

printf "SH ACTION $0 - ARGS:\n"
printf " - %s\n" "$@"
printf "\n\n"

printf "ENV:\n"
printf " - %s\n" env
printf "\n\n"

exit 0
