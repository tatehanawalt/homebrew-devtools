#!/bin/sh
printf "\n\n"

printf "SH ONMAIN $0 - ARGS:\n"
if [ ${#@} -gt 0 ]; then
  printf "\t- %s\n" "$@"
  printf "\n"
else
fi
printf "\n"

printf "ENV:\n"
env
printf "\n\n"

exit 0
