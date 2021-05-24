#!/bin/sh
printf "\n\n"

printf "SH ONMAIN $0 - ARGS:\n"
printf "\t- %s\n" "$@"
printf "\n\n"

printf "ENV:\n"
env
printf "\n\n"

exit 0
