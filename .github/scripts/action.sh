#!/bin/sh
printf "\n\n"

printf "SH ACTION $0 - ARGS:\n"
printf "\t- %s\n" "$@"
printf "\n\n"

printf "ENV:\n"
printf "\t- %s\n" $(env) | sort
printf "\n\n"

exit 0
