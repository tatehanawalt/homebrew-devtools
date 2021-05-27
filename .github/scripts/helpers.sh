#!/bin/bash

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one

INSPECT_GROUPS=$(echo "$INSPECT_GROUPS" | sed 's/^[^[:alpha:]]*//g')

IFS="
"
prefix="    "
in_log=0
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally
[ $in_ci -eq 0 ] && prefix=""

helpers_log_topics=() # Store log headers for pre-exit introspect

before_exit() {
  log BEFORE_EXIT
  printf "%s\n" "${helpers_log_topics[@]}"
  write_result_set $(join_by , ${helpers_log_topics[@]}) BEFORE_EXIT
  log
}

log() {
  [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
  in_log=0
  [ -z "$1" ] && return # Input specified we do not need to start a new log group
  [ $in_ci -eq 1 ] && echo "::group::$1" || echo "$1"
  in_log=1
}

join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }

contains() {
  check=$1
  shift
  printf "$prefix%s\n" "$check"
  [[ $@ =~ (^|[[:space:]])$check($|[[:space:]]) ]] && return 0 || return 1
}

# examples:
#   write_result_set $(join_by , ${exampleset[@]})
#   write_result_set $(join_by , ${exampleset[@]}) $LOG_TOPIC
write_result_set() {
  result="$1"
  result=$(echo -e "$result" | sed 's/"//g')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  KEY="RESULT"
  [ ! -z "$2" ] && KEY="$2"
  echo "$KEY:"
  helpers_log_topics+=($KEY)
  echo $result
  echo "::set-output name=$KEY::$(echo -e $result)"
}






# . $GITHUB_WORKSPACE/.github/scripts/helpers.sh
# Normalize input inspect_groups
# [ ! -z "$INSPECT_GROUPS" ] && INSPECT_GROUPS=$(printf "%s" "$INSPECT_GROUPS" | sed "s/  */\n/g" | sed '/^$/d' | sed 's/^[^[:space:]]/\t&/')





# printf "%s" "$INSPECT_GROUPS"
# printf "%s" "$INSPECT_GROUPS" | sed 's/^[[:space:]]*//g' | sed '/^$/d'
# exit 0

# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   printf "\nwrite_result_set: $1\n"
#   printf "\nwrite_result_set: ${#@}\n"
#   echo
#   echo $result
#   echo
#   echo "::set-output name=RESULT::$(echo -e $result)"
# }






# ESCAPED=$(echo "$ESCAPED" | sed 's/"//g')
# ESCAPED="${ESCAPED//'%'/'%25'}"
# ESCAPED="${ESCAPED//$'\n'/'%0A'}"
# ESCAPED="${ESCAPED//$'\r'/'%0D'}"

# core.addPath	Accessible using environment file GITHUB_PATH
# core.debug	debug
# core.error	error
# core.endGroup	endgroup
# core.exportVariable	Accessible using environment file GITHUB_ENV
# core.getInput	Accessible using environment variable INPUT_{NAME}
# core.getState	Accessible using environment variable STATE_{NAME}
# core.isDebug	Accessible using environment variable RUNNER_DEBUG
# core.saveState	save-state
# core.setFailed	Used as a shortcut for ::error and exit 1
# core.setOutput	set-output
# core.setSecret	add-mask
# core.startGroup	group
# core.warning	warning file

# [ ! -z "$GITHUB_HEAD_REF" ] && HEAD=$GITHUB_HEAD_REF
# [ ! -z "$GITHUB_BASE_REF" ] && BASE=$GITHUB_BASE_REF
# [ ! -z "$GITHUB_REPOSITORY_OWNER" ] && OWNER=$GITHUB_REPOSITORY_OWNER
# [ ! -z "$GITHUB_WORKSPACE" ] && REPO=$GITHUB_WORKSPACE
# GITHUB_API_URL          - https://api.github.com
# GITHUB_AUTH_TOKEN       -
# GITHUB_BASE_REF         - main
# GITHUB_HEAD_REF         - diff_files_Action
# GITHUB_REPOSITORY       - tatehanawalt/homebrew-devtools
# GITHUB_REPOSITORY_OWNER - tatehanawalt
# DEFAULTS

#
# artifacts)
# collaborators)
# collaborator_usernames)
# is_collaborator)
# labels)
# label_names)
# label_ids)
# pull_request)
# pull_request_labels)
# pull_request_label_names)
# pull_request_commits)
# pull_request_files)
# pull_request_merged)
# pull_requests)
# release)
# releases)
# release_assets)
# release_latest)
# release_latest_id)
# release_latest_tag)
# tagged)
# repo_branches)
# repo_branche_names)
# repo_user_permissions)
# repo_contributors)
# repo_contributor_names)
# repo_languages)
# repo_language_names)
# repo_tags)
# repo_teams)
# repo_topics)
# repo_workflow)
# repo_workflows)
# repo_workflow_id)
# repo_workflow_ids)
# repo_workflow_names)
# repo_workflow_runs)
# repo_workflow_completed_runs)
# repo_workflow_run_ids)
# repo_workflow_completed_run_ids)
# repo_workflow_usage)
# workflow_runs)
# workflow_completed_runs)
# workflow_run_ids)
# workflow_completed_run_ids)
# delete_workflow_run)
# workflow_run_numbers)
# workflow_run_job)
# workflow_run_jobs)
# user_repos)
# user_repo_names)


# log() {
#   [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
#   in_log=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
#   in_log=1
# }
# join_by () {
#   local d=${1-} f=${2-};
#   if shift 2; then
#     printf %s "$f" "${@/#/$d}";
#   fi;
# }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   KEY="RESULT"
#   [ ! -z "$2" ] && KEY="$2"
#   echo "$KEY:"
#   echo $result
#   echo "::set-output name=$KEY::$(echo -e $result)"
# }



# log() {
#   [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
#   in_log=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
#   in_log=1
# }
# join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   KEY="RESULT"
#   [ ! -z "$2" ] && KEY="$2"
#   echo "$KEY:"
#   echo $result
#   echo
#   echo "::set-output name=$KEY::$(echo -e $result)"
# }


#IFS="
#"



# log() {
#   [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
#   in_log=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
#   in_log=1
# }
# contains() {
#   check=$1
#   shift
#   [[ $@ =~ (^|[[:space:]])$check($|[[:space:]]) ]] && return 0 || return 1
# }



# IFS="\t"
# for item in ${result[@]}; do printf "%s\n" "$item"; done
# result=$(formula_urls | sed 's/ /,/g')
#formulas=($(formula_names))
#for name in ${formulas[@]}; do
#  printf "%s\n" $name
#  signatures=$(formula_method_signatures $name)
#  for sig in ${signatures[@]}; do
#    formula_method_body $name $sig
#    printf "\n"
#  done
#  printf "\n\n\n"
#done

#dev_parse_formula() {
#  formula_file=$(cat $GITHUB_WORKSPACE/Formula/demozsh.rb)
#  class_name=$(echo "$formula_file" | \
#    grep "class.*" | \
#    sed 's/class[[:space:]]//' | \
#    sed 's/ .*//')
#  header=$(printf "$formula_file" | sed -e '/^$/,$d')
#  header_keys=($(echo "$header" | \
#    sed '/./,$!d' | \
#    grep "[[:alpha:]].*\:" | \
#    sed 's/^[^[:alpha:]]*//g' | \
#    sed 's/ .*//' | \
#    sed 's/:.*//'))
#  header_keys=($(printf "%s\n" ${header_keys[@]} | sort -u))
#  block_lines=$(echo "${formula_file[@]}" | \
#    grep "^  [[:alpha:]]" | \
#    grep -v ".*end.*" | \
#    sed 's/^[^[:alpha:]]*//')
#  block_after_head=$(echo "$block_lines" | sed -n '/head do/,$p' | head -2 | tail -1)
#  echo "$block_after_head"
#  echo "$formula_file"
#  block_after_head="end"
#  echo "$formula_file" | awk '/head do/,/end/'
#  # sed '/^head do$/,/^end$/{//!b};d'
#  # for item in ${header_keys[@]}; do
#  #   printf "\titem: %s\n" $item
#  # done
#  # | sed 's/^# =*//'
#  #  formulas=($(formula_names))
#  #  for item in "${formulas[@]}"; do
#  #    return_set+=("$item:$(formula_url $item)")
#  #  done
#  #  echo "${return_set[@]}"
#}
#exit 0

# echo "$(formula_paths)"
# echo "$(formula_names)"
# echo "$(formula_shas)"
# f_paths=($(formula_paths))
# f_shas=($(formula_shas))
# printf "\tname: %s\n" $name
# for f_path in ${file_paths[@]}; do
#   formula_block_headers "$GITHUB_WORKSPACE/$f_path"
#   echo -e "\n"
# done
# formula_block_headers "$GITHUB_WORKSPACE/Formula/demozsh.rb"

# formula_block_headers() {
#   formula_file=$(cat $1)
#   blocks=($(echo "$formula_file" | grep "^  [[:alpha:]]"))
#   header_blocks=()
#   for ((i=0; i<${#blocks[@]}; i++)); do
#     if  [[ "${blocks[$i]}" =~ "end" ]]; then
#       add_row=${blocks[$((i-1))]}
#       header_blocks+=(${add_row})
#     fi
#   done
#   for block in ${header_blocks[@]}; do
#     printf "%s\n" $block | sed 's/^[[:space:]]*//'
#     echo "$formula_file" | awk "/$block\$/,/^  end/" | sed 1d | sed '$d'
#   done
# }



# log() {
#   [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::"
#   in_log=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
#   in_log=1
# }
# join_by () { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   printf "\nwrite_result_set: $1\n"
#   printf "\nwrite_result_set: ${#@}\n"
#   echo
#   echo $result
#   echo
#   echo "::set-output name=RESULT::$(echo -e $result)"
# }



# printf "helpers_log_topics\n"
# printf "%s\n" ${helpers_log_topics[@]}
# HEAD is the branch
# BASE is the main
# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# in_log=0
# in_ci=1
# [ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally
# log() {
#   [ $in_log -ne 0 ] && [ $in_ci -eq 0 ] && echo "::endgroup::" || echo -e "\n"
#   in_log=0
#   [ -z "$1" ] && return # Input specified we do not need to start a new log group
#   [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1"
#   in_log=1
# }
# join_by () {
#   local d=${1-} f=${2-};
#   if shift 2; then
#     printf %s "$f" "${@/#/$d}";
#   fi;
# }
# write_result_set() {
#   result="$1"
#   result=$(echo -e "$result" | sed 's/"//g')
#   result="${result//'%'/'%25'}"
#   result="${result//$'\n'/'%0A'}"
#   result="${result//$'\r'/'%0D'}"
#   KEY="RESULT"
#   [ ! -z "$2" ] && KEY="$2"
#   echo "$KEY:"
#   echo "$result"
#   echo "::set-output name=$KEY::$(echo -e $result)"
# }


# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# in_log=0
# in_ci=1
# [ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally


# DO NOT MODIFY IFS!
# IFS="
# "
# in_log=0
# in_ci=1
# IF RUN BY CI vs Locally
# [ "$CI" = "true" ] && in_ci=0



# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
# log() {
#   if [ $in_log -ne 0 ]; then
#     [ $in_ci -eq 0 ] && echo "::endgroup::";
#     in_log=0
#   fi
#   # Do we need to start a group?
#   if [ ! -z "$1" ]; then
#     [ $in_ci -eq 0 ] && echo "::group::$1" || echo "$1:"
#     in_log=1
#   fi
# }


# printf "inc"
# in_log=0
# in_ci=1
# [ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally



# for group in ${groups[@]}; do
  # printf "\t%s\n" "$group"
  # group=$(printf "%s" "$group" | xargs)
  # printf "$prefix%s\n" "$(printf "%s" "$group" | sed 's/=.*//' | tr '[:lower:]' '[:upper:]')"
# done

# groups=($(printf "%s" "${INSPECT_GROUPS[@]}" | xargs | tr '[:space:]' '\n'))
# printf "%s\n" ${groups[@]}
# for g in "${groups[@]}"; do
#  printf "g: %s\n\n" "$g"
# done

# groups=$(printf "%s" "$INSPECT_GROUPS" | sed 's/^ \s*//g' | sed '/^$/d' )
# groups=$(printf "%s" "$INSPECT_GROUPS" | tr -s ' ' | sed '/^$/d' )
# groups=($(printf "%s" "$INSPECT_GROUPS" | tr -s ' ' | sed '/^$/d' ))
