#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

can_exec=0
add_label_set=()

[ -z "$GITHUB_BASE_REF" ] && GITHUB_BASE_REF=main # original ref
[ -z "$GITHUB_HEAD_REF" ] && GITHUB_HEAD_REF=main # current ref
# Using the BASE branch
[ -z "$GITHUB_BASE_REF" ]     && write_error "$(basename $0) GITHUB_BASE_REF length is 0... set GITHUB_BASE_REF=<branch_name> - line $LINENO" && can_exec=1
[ -z "$GITHUB_WORKSPACE" ]    && write_error "$(basename $0) GITHUB_WORKSPACE length is 0 - line $LINENO" && can_exec=1
[ ! -d "$GITHUB_WORKSPACE" ]  && write_error "$(basename $0) GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE - line $LINENO" && can_exec=1
[ $can_exec -ne 0 ]           && write_error "can_exec -ne 0... can_exec=$can_exec - line $LINENO" && exit 1

git fetch origin "$GITHUB_BASE_REF" &>/dev/null
git branch "$GITHUB_BASE_REF" FETCH_HEAD &>/dev/null

[ -z $(git branch --list "$GITHUB_BASE_REF") ] && write_error "$(basename $0) FETCH_HEAD for branch $GITHUB_BASE_REF - line $LINENO" && exit 1

diff_files=($(git diff --name-only $GITHUB_BASE_REF | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g' | sort -u))
diff_files_csv=$(join_by , ${diff_files[@]})
write_result_set "$diff_files_csv" diff_files

diff_dirs=($(for_csv "$diff_files_csv" dirname | sort -u))
write_result_set $(join_by , ${diff_dirs[@]}) diff_dirs

diff_ext=()

for f_path in ${diff_files[@]}; do
  filename="${f_path##*/}"
  ext_name="$(echo $filename | sed 's/^[^\.]*//')"
  [ "$ext_name" = "$filename" ] && continue
  ext_name="$(echo $ext_name | sed 's/^\.//')"
  [ -z "$ext_name" ] && continue
  diff_ext+=("$ext_name")
done

diff_ext=($(printf "%s\n" ${diff_ext[@]} | sort -u))
write_result_set $(join_by , ${diff_ext[@]}) diff_ext

for dir_path in ${diff_dirs[@]}; do
  case $dir_path in
    # Formula) add_label_set+=( brew );;
    Formula) add_label_set+=(":beer:");;
    .github/workflows | .github/scripts) add_label_set+=( action );;
  esac
done

for fname in ${diff_files[@]}; do
  case $fname in
    # Formula/*.rb) add_label_set+=( formula brew $(basename $fname | sed 's/\..*//') );;
    Formula/*.rb) add_label_set+=( formula ":beer:" $(basename $fname | sed 's/\..*//') );;
  esac
done

for ext in ${diff_ext[@]}; do
  case $ext in
    c)    add_label_set+=(c);;
    cpp)  add_label_set+=(cpp);;
    json) add_label_set+=(json);;
    md)   add_label_set+=( documentation markdown );;
    py)   add_label_set+=(python);;
    rb)   add_label_set+=(ruby);;
    sh)   add_label_set+=(shell) ;;
    svg)  printf "svg - leave this for now...\n" ;;
    yaml) add_label_set+=(yaml) ;;
    yml)
      add_label_set+=(yaml)
      echo "::warning file=$(basename $0),line=$LINENO::Encountered a yml file... $(basename $0):$LINENO"
      ;;
    *) write_error "$(basename $0) Unhandled Extension $ext - line $LINENO" ;;
  esac
done

diff_add_label_set=($(printf "%s\n" ${add_label_set[@]} | sed 's/.*\.//' | sort -u))
write_result_set $(join_by , ${diff_add_label_set[@]}) diff_add_label_set

before_exit
