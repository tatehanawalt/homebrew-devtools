#!/bin/sh

# GITHUB_WORKSPACE=/usr/local/Homebrew/Library/Taps/tatehanawalt/homebrew-devtools
# GITHUB_WORKSPACE=/usr/local/Homebrew/Library/Taps/tatehanawalt/homebrew-devtools ./parseaction.sh

COMPARE_BRANCH=dev
if [ -z "$COMPARE_BRANCH" ]; then
  printf "\$COMPARE_BRANCH length is 0..." 1>&2;
  exit 2
fi

# Make sure we are in the github workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE length is 0..." 1>&2;
  exit 2
fi
if [ ! -d "$GITHUB_WORKSPACE" ]; then
  printf "\$GITHUB_WORKSPACE is not a directory at GITHUB_WORKSPACE=$GITHUB_WORKSPACE" 1>&2;
  exit 2
fi

cd $GITHUB_WORKSPACE
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  printf "\n\nFETCHING COMPARE BRANCH: $COMPARE_BRANCH\n\n"
  git fetch origin $COMPARE_BRANCH
  git branch dev FETCH_HEAD
fi
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  printf "\n\nFETCH_HEAD for branch $COMPARE_BRANCH\n" 1>&2;
  exit 2
fi

diff_files=$(git diff --name-only "$COMPARE_BRANCH")
lint_files=""
lint_extensions=""

for f_path in $diff_files; do
  full_path="$GITHUB_WORKSPACE/$f_path"
  if [ -z "$full_path" ]; then
    printf "full_path length is 0..." 1>&2;
    exit 2
  fi
  if [ -z "$full_path" ]; then
    continue
  fi
  if [ -f "$full_path" ]; then
    lint_files="${lint_files[@]}$full_path\n"
    modified_ext=$(echo "$full_path" | sed 's/.*\.//g')
    if [ ! -z "$modified_ext" ]; then
      lint_extensions="$lint_extensions$modified_ext\n"
    fi
  fi
done



printf "${lint_files[@]}" | while read line || [[ -n $line ]];
do
    echo "line: $line"
done

exit 3


lint_files=$(printf "$lint_files" | sort -u)
printf "LINT FILES: %d\n" "${#lint_files[@]}"
for lint_file in "${lint_files[@]}"; do
  printf "\t$lint_file\n"
done


IFS=\n
lint_extensions=($(printf "$lint_extensions" | sort -u))
printf "LINT EXTENSIONS: %d\n" ${#lint_extensions[@]}
echo ${lint_extensions[@]} | while read line
do
  echo "line: $line"
done


exit 3

for lint_ext in "${lint_extensions[@]}"; do
  echo "\t$lint_ext"
done

printf "\n\nLINT_START=$(date +%s)\n"


for ext in ${lint_extensions[@]}; do
  echo "$ext"
  case "$ext" in
    md)
      lint_set=$(echo "${lint_files[@]}" | tr ' ' '\n' | grep "$ext")
      for lint_file in ${lint_set[@]}; do
        printf "\t%s\n" "$lint_file"
      done
      ;;
    rb)
      lint_set=$(echo "${lint_files[@]}" | tr ' ' '\n' | grep "$ext")
      for lint_file in ${lint_set[@]}; do
        printf "\tLINTING=%s\n" "$lint_file"
        lint_results=$(rubocop $lint_file)
        lint_exit_code=$?
        printf "\tEXIT_CODE=$lint_exit_code\n"
        printf "$lint_results\n" | sed 's/^/\t/'
        if [ $lint_exit_code -ne 0 ]; then
          printf "\n\n"
          exit 2
        fi
      done
      ;;
    sh)
      lint_set=$(echo "${lint_files[@]}" | tr ' ' '\n' | grep "$ext")
      for lint_file in ${lint_set[@]}; do
        printf "\t%s\n" "$lint_file"
      done
      ;;
    yml)
      lint_set=$(echo "${lint_files[@]}" | tr ' ' '\n' | grep "$ext")
      for lint_file in ${lint_set[@]}; do
        printf "\tLINTING=%s\n" "$lint_file"
        lint_results=$(ruby -ryaml -e "p YAML.load(STDIN.read)" < $lint_file)
        lint_exit_code=$?
        printf "\tEXIT_CODE=$lint_exit_code\n"
        printf "$lint_results\n" | sed 's/^/\t/'
        if [ $lint_exit_code -ne 0 ]; then
          printf "\n\n"
          exit 2
        fi
      done
      ;;
    yaml)
      lint_set=$(echo "${lint_files[@]}" | tr ' ' '\n' | grep "$ext")
      for lint_file in ${lint_set[@]}; do
        printf "\tLINTING=%s\n" "$lint_file"
        lint_results=$(ruby -ryaml -e "p YAML.load(STDIN.read)" < $lint_file)
        lint_exit_code=$?
        printf "\tEXIT_CODE=$lint_exit_code\n"
        printf "$lint_results\n" | sed 's/^/\t/'
        if [ $lint_exit_code -ne 0 ]; then
          printf "\n\n"
          exit 2
        fi
      done
      ;;
    *)
      printf "UNHANDLED_EXTENSION=%s\n" "$ext"  1>&2;
      exit 2
      ;;
  esac
done

exit 0




# printf "SH ONMAIN $0 - ARGS:\n"
# if [ ${#@} -gt 0 ]; then
#   printf "\t- %s\n" "$@"
#   printf "\n"
# fi
# printf "\n"
# printf "ENV:\n"
# env | sort
# printf "\n\n"
# # ENV VARS:
# # GITHUB_ACTIONS = Always set to true when GitHub Actions is running the workflow. You can use this variable to differentiate when tests are being run locally or by GitHub Actions.
# printf "%-12s%s\n" action "$GITHUB_ACTION"
# printf "%-12s%s\n" trigger "$GITHUB_EVENT_NAME"
# printf "%-12s%s\n" repo "$GITHUB_WORKSPACE"
# printf "%-12s%s\n" commit "$GITHUB_SHA"
# if [ ! -z "$GITHUB_HEAD_REF" ] && [ ! -z "$GITHUB_REF" ]; then
#   printf "\nPR ACTION\n"
# fi
