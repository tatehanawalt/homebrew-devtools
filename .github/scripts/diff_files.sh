#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

[ -z "$GITHUB_BASE_REF" ] && GITHUB_BASE_REF=main # original ref
[ -z "$GITHUB_HEAD_REF" ] && GITHUB_HEAD_REF=main # current ref

# Using the BASE branch
[ -z "$GITHUB_BASE_REF" ]    && write_error "$(basename $0) GITHUB_BASE_REF length is 0... set GITHUB_BASE_REF=<branch_name> - line $LINENO" && exit 1
[ -z "$GITHUB_WORKSPACE" ]   && write_error "$(basename $0) GITHUB_WORKSPACE length is 0 - line $LINENO" && exit 1
[ ! -d "$GITHUB_WORKSPACE" ] && write_error "$(basename $0) GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE - line $LINENO" && exit 1

diff_files=()
diff_ext=()
diff_dirs=()
diff_labels=()

git fetch origin "$GITHUB_BASE_REF" &>/dev/null
git branch "$GITHUB_BASE_REF" FETCH_HEAD &>/dev/null

[ -z $(git branch --list "$GITHUB_BASE_REF") ] && write_error "$(basename $0) FETCH_HEAD for branch $GITHUB_BASE_REF - line $LINENO" && exit 1

function on_label() {
  [ -z "$1" ] && write_error "on_label \$1 length is zero - line $LINENO" && return 1
  diff_labels+=("$1")
  case "$1" in
    "brew")
      diff_labels+=(":beer:")
      ;;
    "formula")
      on_label "brew"
      ;;
  esac
}
function on_ext() {
  [ -z "$1" ] && write_error "on_ext \$1 length is zero - line $LINENO" && return 1
  diff_ext+=("$1")
  case $1 in
    c)
      on_label "c"
      ;;
    cpp)
      on_label "cpp"
      ;;
    json)
      on_label "json"
      ;;
    md)
      on_label "documentation"
      on_label "markdown"
      ;;
    py)
      on_label "python"
      ;;
    rb)
      on_label "ruby"
      ;;
    sh)
      on_label "shell"
      ;;
    svg)
      printf "svg - leave this for now...\n"
      ;;
    yaml)
      on_label "yaml"
      ;;
    yml)
      on_label "yaml"
      echo "::warning line=$LINENO::Encountered a yml extension... $1"
      ;;
    *)
      write_error "Unhandled Extension '$1' - line $LINENO"
      ;;
  esac
}
function on_dir() {
  [ -z "$1" ] && write_error "on_dir \$1 length is zero - line $LINENO" && return 1
  diff_dirs+=($1)
  case $1 in
    Formula)
      on_label "formula"
      ;;
    .github/workflows | .github/scripts)
      on_label "action"
      ;;
  esac
}
function on_file_path() {
  [ -z "$1" ] && write_error "on_file_path \$1 length is zero - line $LINENO" && return 1
  diff_files+=($1)
  on_dir "$(dirname $1)"
  on_ext "$(echo ${1##*/} | sed 's/^[^\.]*//' | sed 's/^\.//')"
  case $1 in
    Formula/*.rb)
      on_label "$(basename $1 | sed 's/\..*//')"
      ;;
  esac
}

for fpath in $(git diff --name-only $GITHUB_BASE_REF | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g');
do on_file_path "$fpath"; done

write_result_set "$(join_by , $(printf "%s\n" ${diff_files[@]} | sort -u))" "files"
write_result_set "$(join_by , $(printf "%s\n" ${diff_ext[@]} | sort -u))" "extensions"
write_result_set "$(join_by , $(printf "%s\n" ${diff_dirs[@]} | sort -u))" "directories"
write_result_set "$(join_by , $(printf "%s\n" ${diff_labels[@]} | sort -u))" "labels"

before_exit
