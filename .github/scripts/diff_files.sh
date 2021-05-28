#!/bin/bash

. "$(dirname $0)/helpers.sh"

printf "This is a debug statement\n"
echo "::debug::Set the Octocat variable"


add_label_set=()



#  Compare against the main branch
[ -z "$GITHUB_BASE_REF" ] && GITHUB_BASE_REF=main # original ref
[ -z "$GITHUB_HEAD_REF" ] && GITHUB_HEAD_REF=main # current ref

# Using the BASE branch
if [ -z "$GITHUB_BASE_REF" ]; then
  echo "GITHUB_BASE_REF length is 0... set GITHUB_BASE_REF=<branch_name>"
  exit 2
fi

echo "GITHUB_BASE_REF=$GITHUB_BASE_REF"
if [ -z "$GITHUB_WORKSPACE" ]; then
  echo "GITHUB_WORKSPACE length is 0"
  exit 2
fi

if [ ! -d "$GITHUB_WORKSPACE" ]; then
  echo "GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
  exit 2
fi

git fetch origin "$GITHUB_BASE_REF" &>/dev/null
git branch "$GITHUB_BASE_REF" FETCH_HEAD &>/dev/null

# has_diff_branch=$(git branch --list "$GITHUB_BASE_REF")
if [ -z $(git branch --list "$GITHUB_BASE_REF") ]; then
  echo "FETCH_HEAD for branch $GITHUB_BASE_REF"
  exit 2
fi

printf "This is a debug statement\n"
echo "::debug::Another the Octocat variable"

IFS=$'\n'
diff_files=($(git diff --name-only $GITHUB_BASE_REF | sed 's/[[:space:]]$//g' | sed 's/^[[:space:]]//g'))
diff_files_csv=$(join_by , ${diff_files[@]})
write_result_set "$diff_files_csv" "DIFF_FILES"

diff_dirs=($(for_csv "$diff_files_csv" dirname | sort -u))
diff_dirs_csv=$(join_by , ${diff_dirs[@]})
write_result_set "$diff_dirs_csv" "DIFF_DIRS"

diff_ext=($(printf "%s\n" ${diff_files[@]} | sed 's/.*\.//' | sort -u))
diff_ext_csv=$(join_by , ${diff_ext[@]})
write_result_set "$diff_ext_csv" "DIFF_EXT"



for ext in ${diff_ext[@]}; do
  case $ext in
    c)
      printf "c\n"
      ;;
    cpp)
      printf "c++\n"
      ;;
    md)
      printf "markdown\n"
      add_label_set+=( "documentation" )
      add_label_set+=( "markdown" )
      ;;
    json)
      printf "json\n"
      add_label_set+=( "json" )

      ;;
    rb)
      printf "ruby\n"
      add_label_set+=( "ruby" )

      ;;
    py)
      printf "python\n"
      add_label_set+=( "python" )

      ;;
    yaml)
      printf "yaml\n"
      add_label_set+=( "yaml" )
      ;;
    yml)
      printf "yml\n"
      add_label_set+=( "yaml" )
      echo "::warning file=$(basename $0),line=$LINENO::Encountered a yml file... $(basename $0):$LINENO"

      ;;
    *)
      printf "UNHANDLED EXT: %s\n" $ext
      echo "::warning file=$(basename $0),line=$LINENO::Unhandled Extension $ext in $(basename $0):$LINENO"
      ;;
  esac
done

for ext in ${diff_ext[@]}; do
  case $ext in
    Formula)
      printf "\n\n\nFOUND A Formula BREW TAG CHANGE!\n\n"
      add_label_set+=( "brew" )
      ;;
  esac
done


for fname in ${diff_files[@]}; do
  case $fname in
    Formula/*.rb)
      printf "\n\n\nFOUND A BREW TAG CHANGE!\n\n"
      add_label_set+=( "formula" )
      add_label_set+=( $(basename $fname | sed 's/\..*//') )
      ;;
  esac
done




diff_add_label_set=($(printf "%s\n" ${add_label_set[@]} | sed 's/.*\.//' | sort -u))
diff_add_label_set_csv=$(join_by , ${diff_add_label_set[@]})
write_result_set "$diff_add_label_set_csv" diff_add_label_set




before_exit
exit 0


# printf "This is a debug statement\n"
# echo "::debug::Another the Octocat variable"
# echo "::warning file=app.js,line=1,col=5::Missing semicolon"
# printf "%s\n" ${diff_files[@]}
#    sh)
#      printf "shell\n"
#      ;;
# echo "::error file=app.js,line=10,col=15::ERROR Unhandled Extension: $ext in $(basename $0):$LINENO"
# echo "::warning file=app.js,line=1,col=5::Missing semicolon"
