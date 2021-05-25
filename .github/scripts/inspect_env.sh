#!/bin/sh

ENV_MAP=$(env)

printf "ENV:\n"
printf "\t%s\n" $ENV_MAP | sort -u
