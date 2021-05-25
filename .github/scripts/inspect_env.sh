#!/bin/sh

# Used as a debugging script to see what an environment looks like

ENV_MAP=$(env)
printf "ENV:\n"
printf "\t%s\n" $ENV_MAP | sort -u
