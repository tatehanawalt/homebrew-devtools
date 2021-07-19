#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

add_labels=()

function on_label() {
  [ -z "$1" ] && write_error "on_label \$1 length is zero - line $LINENO" && return 1
  add_labels+=("$1")
  case $1 in
    brew)
      on_label ":beer:"
      ;;
    formula)
      on_label "brew"
      ;;
  esac
}

for_csv "$LABELS_CSV" on_label
add_labels=($(printf "%s\n" ${add_labels[@]} | sort -u))

can_exec=0
[ -z "$GITHUB_REPOSITORY" ]       && write_error "GITHUB_REPOSITORY not set in label_pr - line $LINENO"       && can_exec=1
[ -z "$GITHUB_REPOSITORY_OWNER" ] && write_error "GITHUB_REPOSITORY_OWNER not set in label_pr - line $LINENO" && can_exec=1
[ -z "$ID" ]                      && write_error "ID not set in label_pr - line $LINENO"                      && can_exec=1
[ ${#add_labels[@]} -lt 1 ]       && write_error "add_labels count < 1. - line $LINENO"                       && can_exec=1

json_data=$(printf "%s\n" "${add_labels[@]}" | jq -R . | jq -s -c .)

args=(--url 'repos/{owner}/{repo}/issues/{id}/labels')
args+=(--method POST)
args+=(--id $ID)
args+=(--auth)
args+=(--json-body $json_data)
args+=(--owner $GITHUB_REPOSITORY_OWNER)
args+=(--repo "$(printf %s $GITHUB_REPOSITORY | sed 's/.*\///')")

# DEBUG:
# printf "args:\n"; printf "\t%s\n" ${args[@]}

[ $can_exec -ne 0 ] && write_error "can_exec -ne 0 - line $LINENO" && exit 1
git_req ${args[@]}
before_exit
