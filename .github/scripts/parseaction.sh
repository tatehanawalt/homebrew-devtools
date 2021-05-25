#!/bin/sh

COMPARE_BRANCH=dev
bold_div_line="======================================================================================================="
div_line="-------------------------------------------------------------------------------------------------------"
item_prefix="- "

printf "%s\n" "$bold_div_line"
printf "LINTING RESULTS AT THE BOTTOM OF THE LOG\n"
printf "%s\n" "$bold_div_line"

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

# Takes the FULL filepath of a file to lint
lint_fs_file () {
  ext=$(echo "$1" | sed 's/.*\.//g')
  lint_results=""
  lint_exit_code=0
  case "$ext" in
    md)
      lint_exit_code=0
      ;;
    rb)
      lint_results=$(rubocop "$1" 2>&1)
      lint_exit_code=$?
      if [ $lint_exit_code -ne 0 ]; then
        printf "\n\tRUBY FAILURE - try running rubocop with --auto-correct\n\n"
      fi
      ;;
    sh)
      lint_exit_code=0
      ;;
    yml)
      lint_results=$(ruby -ryaml -e "p YAML.load(STDIN.read)" < $1 2>&1)
      lint_exit_code=$?
      [ "$lint_results" = "false" ] && lint_exit_code=2
      ;;
    yaml)
      lint_results=$(ruby -ryaml -e "p YAML.load(STDIN.read)" < $1 2>&1)
      lint_exit_code=$?
      [ "$lint_results" = "false" ] && lint_exit_code=2
      ;;
    *)
      lint_results=$(printf "UNHANDLED_EXTENSION=%s\n" "$ext")
      lint_exit_code=2
      ;;
  esac
  if [ ! -z "$lint_results" ]; then
    printf "$lint_results\n" | sed 's/^/\t/'
  fi
  return $lint_exit_code
}

cd $GITHUB_WORKSPACE
has_dif_branch=$(git branch --list "$COMPARE_BRANCH")
if [ -z "$has_dif_branch" ]; then
  git fetch origin $COMPARE_BRANCH
  git branch dev FETCH_HEAD
  fetch_exit_code=$?
  printf "fetch_exit_code=$fetch_exit_code\n"
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
    lint_files="$lint_files$full_path\n"
    modified_ext=$(echo "$full_path" | sed 's/.*\.//g')
    if [ ! -z "$modified_ext" ]; then
      lint_extensions="$lint_extensions$modified_ext\n"
    fi
  fi
done

IFS="
"
# This part just logs the linting set
lint_files=$(echo "$lint_files" | sort -u )
printf "FILES:\n"
for f_path in $lint_files; do
  printf "%s%s\n" "$item_prefix" "$f_path"
done
lint_extensions=$(echo "$lint_extensions" | sort -u )
printf "EXTENSIONS:\n"
for ext in $lint_extensions; do
  printf "%s%s\n" "$item_prefix" "$ext"
done

for ext in $lint_extensions; do
  case "$ext" in

    rb)
      printf "Will lint ruby\n"
      rubocop --version
      ruby --version
      ;;

  esac
done


# Actually lint the files
lint_failures=""
for ext in $lint_extensions; do
  printf "%s\n" "$div_line"
  printf "EXT=$ext\n"
  lint_set=$(echo "$lint_files" | grep "$ext\$" | sort -u)
  for lint_file in $lint_set; do
    printf "%sFILE=%s\n" "$item_prefix" "$lint_file"
    lint_fs_file $lint_file
    if [ $? -ne 0 ]; then
      lint_failures="$lint_failures$lint_file\n"
    fi
  done
done

if [ ! -z "$lint_failures" ]; then
  printf "%s\n" "$bold_div_line"
  printf "LINTING=failed\n"
  printf "FILES:\n"
  lint_failures=$(echo "$lint_failures" | sort -u)
  for failed_lint in $lint_failures; do
    printf "%s%s\n" "$item_prefix" "$failed_lint"
  done
  printf "%s\n" "$bold_div_line"
  exit 1
fi
exit 0
