#!/bin/bash

. "$(dirname $0)/helpers.sh"

# These are global args like enter debug and stuff
for arg in $@; do
  case $arg in
    -d) debug_mode=0;; # print debug logging
    -o) write_out=0;;  # write the result to standard output
  esac
done

[ $debug_mode -eq 0 ] && printf "debug_mode: %d\n" $debug_mode

run_input() {
  if [ $debug_mode -eq 0 ]; then
    printf "run_input:\n"
    printf "%s\n" ${@}
  fi

  request_url='' # url request path
  args=()
  search_string=''

  case $1 in
    artifacts)
      request_url='repos/{owner}/{repo}/actions/artifacts'
      ;;
    collaborators)
      request_url='repos/{owner}/{repo}/collaborators'
      args+=(--auth)
      ;;
    collaborator_names)
      request_url='repos/{owner}/{repo}/collaborators/{user}'
      search_string='. | map(.login) | join(",")'
      ;;
    is_collaborator)
      request_url='repos/{owner}/{repo}/collaborators/{user}'
      args+=(--auth)
      ;;
    help)
      echo "
      artifacts
      collaborators
      collaborator_usernames
      is_collaborator
      labels
      label_names
      label_ids
      pull_request
      pull_request_labels
      pull_request_label_names
      pull_request_commits
      pull_request_files
      pull_request_merged
      pull_requests
      release
      releases
      release_assets
      release_latest
      release_latest_id
      release_latest_tag
      tagged
      repo_branches
      repo_branch_names
      repo_user_permissions
      repo_contributors
      repo_contributor_names
      repo_languages
      repo_language_names
      repo_tags
      repo_teams
      repo_topics
      repo_workflow
      repo_workflows
      repo_workflow_id
      repo_workflow_ids
      repo_workflow_names
      repo_workflow_runs
      repo_workflow_completed_runs
      repo_workflow_run_ids
      repo_workflow_completed_run_ids
      repo_workflow_usage
      workflow_runs
      workflow_completed_runs
      workflow_run_ids
      workflow_completed_run_ids
      delete_workflow_run
      workflow_run_numbers
      workflow_run_job
      workflow_run_jobs
      user_repos
      user_repo_names" | sort
      exit 1
      ;;
    labels)
      request_url='repos/{owner}/{repo}/labels'
      ;;
    label_names)
      request_url='repos/{owner}/{repo}/labels'
      search_string='. | map(.name) | join (",")'
      # search_string='. | map(.name) | join(",")'
      ;;
    label_ids)
      request_url='repos/{owner}/{repo}/labels'
      search_string='. | map(.id) | join(",")'
      ;;
    pull_request)
      request_url='repos/{owner}/{repo}/pulls/{id}'
      ;;
    pull_request_labels)
      request_url='repos/{owner}/{repo}/pulls/{id}'
      write_error "todo - specify search string for .labels field"
      exit 1
      ;;
    pull_request_label_names)
      request_url='repos/{owner}/{repo}/pulls/{id}'
      search_string='[.labels[]] | map(.name) | join(",")'
      ;;
    pull_request_commits)
      request_url='repos/{owner}/{repo}/pulls/{id}/commits'
      ;;
    pull_request_files)
      request_url='repos/{owner}/{repo}/pulls/{id}/files'
      ;;
    pull_request_merged)
      request_url='repos/{owner}/{repo}/pulls/{id}/merge'
      ;;
    pull_requests) # ✔
      request_url='repos/{owner}/{repo}/pulls'
      ;;
    release)
      request_url='repos/{owner}/{repo}/releases/{release_id}'
      ;;
    releases)
      request_url='repos/{owner}/{repo}/releases'
      ;;
    release_assets)
      request_url='repos/{owner}/{repo}/releases/{release_id}/assets'
      ;;
    release_latest)
      request_url='repos/{owner}/{repo}/releases/latest'
      ;;
    release_latest_id)
      request_url='repos/{owner}/{repo}/releases/latest'
      write_error "todo - specify search string for .id field"
      exit 1
      ;;
    release_latest_tag)
      request_url='repos/{owner}/{repo}/releases/latest'
      write_error "todo - specify search string for .tag_name field"
      exit 1
      ;;
    tagged)
      request_url='repos/{owner}/{repo}/releases/tags/{tag}'
      ;;
    repo_branches) # ✔
      request_url='repos/{owner}/{repo}/branches'
      ;;
    repo_branch_names)
      request_url='repos/{owner}/{repo}/branches'
      search_string='. | map(.name) | join(",")'
      ;;
    repo_user_permissions)
      request_url='repos/{owner}/{repo}/collaborators/{user}/permission'
      args+=(--auth)
      ;;
    repo_contributors)
      request_url='repos/{owner}/{repo}/contributors'
      write_error "todo - specify search string for .name field"
      exit 1
      ;;
    repo_contributor_names)
      request_url='repos/{owner}/{repo}/contributors'
      search_string='. | map(.login) | join(",")'
      ;;
    repo_languages)
      request_url='repos/{owner}/{repo}/languages'
      ;;
    repo_language_names)
      request_url='repos/{owner}/{repo}/languages'
      search_string='keys | join("\n")'
      ;;
    repo_tags)
      request_url='/repos/{owner}/{repo}/tags'
      args+=(--auth)
      ;;
    repo_teams)
      request_url='repos/{owner}/{repo}/teams'
      args+=(--auth)
      ;;
    repo_topics)
      request_url='repos/{owner}/{repo}/topics'
      args+=(--auth)
      ;;
    repo_workflow)
      request_url='repos/{owner}/{repo}/actions/workflows/{id}'
      ;;
    repo_workflow_id)
      request_url='repos/{owner}/{repo}/actions/workflows'
      field_val=$NAME
      search_string='.workflows | .[] | select(.name == $field_name) | .id'
      ;;
    repo_workflows)
      request_url='repos/{owner}/{repo}/actions/workflows'
      ;;
    repo_workflow_ids)
      request_url='repos/{owner}/{repo}/actions/workflows'
      search_string='.workflows | map(.id) | join(",")'
      ;;
    repo_workflow_names)
      request_url='repos/{owner}/{repo}/actions/workflows'
      search_string='.workflows | map(.name) | join(",")'
      ;;
    repo_workflow_runs)
      request_url='repos/{owner}/{repo}/actions/runs'
      ;;
    repo_workflow_completed_runs)
      request_url='repos/{owner}/{repo}/actions/runs'
      search_string='[.workflow_runs[] | select(.status == "completed")]'
      ;;
    repo_workflow_run_ids)
      request_url='repos/{owner}/{repo}/actions/runs'
      search_string='.workflow_runs | map(.id) | join(",")'
      ;;
    repo_workflow_completed_run_ids)
      request_url='repos/{owner}/{repo}/actions/runs'
      search_strinig='[.workflow_runs[] | select(.status == "completed")] | map(.id) | join(",")'
      ;;
    #repo_workflow_usage)
    #  QUERY_BASE=actions/workflows/$ID/timing
    #  ;;
    workflow_runs)
      request_url='repos/{owner}/{repo}/workflows/{id}/runs'
      ;;
    workflow_completed_runs)
      request_url='repos/{owner}/{repo}/workflows/{id}/runs'
      search_string='[.workflow_runs[] | select(.status == "completed")]'
      ;;
    workflow_run_ids)
      request_url='repos/{owner}/{repo}/workflows/{id}/runs'
      search_string='.workflow_runs | map(.id) | join(",")'
      ;;
    workflow_completed_run_ids)
      request_url='repos/{owner}/{repo}/workflows/{id}/runs'
      search_string='[.workflow_runs[] | select(.status == "completed")] | map(.id) | join(",")'
      ;;
    delete_workflow_run)
      request_url='repos/{owner}/{repo}/actions/runs/{id}'
      args+=(--method DELETE)
      args+=(--auth)
      ;;
    workflow_run_numbers)
      QUERY_BASE=actions/workflows/$ID/runs
      SEARCH_STRING='.workflow_runs | map(.run_number) | join(",")'
      ;;
    workflow_run_job)
      request_url='repos/{owner}/{repo}/actions/jobs/{job_id}'
      ;;
    workflow_run_jobs)
      request_url='repos/{owner}/{repo}/actions/runs/{run_id}/jobs'
      ;;
    user_repos)
      request_url='users/{user}/repos'
      ;;
    user_repo_names)  # ✔
      request_url='users/{user}/repos'
      search_string='.[] | .name'
      ;;
    *)
      write_error "$(basename $0) target $1 not recognized - line $LINENO"
      exit 1
      ;;
  esac

  args+=(--url)
  args+=("$request_url")
  depts=($(echo "$request_url" | grep -o '{[[:alpha:]]*}' | grep -o '[^{][[:alpha:]]*[^}]'))
  for dep in ${depts[@]}; do
    case $dep in
      'owner') args+=(--owner $GITHUB_REPOSITORY_OWNER);;
      'repo') args+=(--repo $(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'));;
      'user') args+=(--user tatehanawalt);;
      *)
        write_error "unrecognized dependency $dep\n"
        before_exit
        exit 1
        ;;
    esac
  done

  if [ $debug_mode -eq 0 ]; then
    printf "args:\n"
    printf " • %s\n" ${args[@]}
    git_req ${args[@]}
    printf "git_req exit_code=$?\n"
    before_exit
    exit 1
  fi

  results=($(git_req ${args[@]}))
  exit_code=${results[0]}
  printf "exit_code: %d\n" $exit_code
  [ $write_out -eq 0 ] && echo "${results[@]:1}" | jq
  if [ ! -z "$search_string" ]; then
    echo "${results[@]:1}" | jq --arg field_name "$field_val" -r $search_string
  fi
  before_exit
  exit 0
}

for cmd in $(echo "$template" | tr ',' '\n'); do
  printf "cmd: %s\n" ${cmd}
  run_input $cmd

  # log $cmd
  # request_status=0
  # run_input $cmd
  # echo -e "\nrequest_status: $request_status\n"
  # [ $request_status -ne 0 ] && break
done

before_exit
exit $request_status



# IFS=$'\n'

# TOPIC=users
# QUERY_BASE=repos
# QUERY_URL="$GITHUB_API_URL/$TOPIC/$USER/$QUERY_BASE"
# field_label="${USER}_repos"

# search_field=name
# request_url='users/$USER/repos'
# TOPIC=users
# QUERY_BASE=repos
# QUERY_URL="$GITHUB_API_URL/$TOPIC/$USER/$QUERY_BASE"
# SEARCH_FIELD=name
# field_label="${USER}"

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

# if [ $WITH_DELETE -eq 0 ]; then
# response=$(curl \
#   -X DELETE \
#   -s \
#   -w "HTTPSTATUS:%{http_code}" \
#   -H "Authorization: token $GITHUB_AUTH_TOKEN" \
#   -H "Accept: application/vnd.github.v3+json" \
#   $QUERY_URL)
# else

# if [ ! -z "$GITHUB_AUTH_TOKEN" ]; then
# response=$(curl \
#   -s \
#   -w "HTTPSTATUS:%{http_code}" \
#   -H "Authorization: token $GITHUB_AUTH_TOKEN" \
#   -H "Accept: application/vnd.github.v3+json" \
#   $QUERY_URL)
# else
# response=$(curl \
#   -s \
#   -w "HTTPSTATUS:%{http_code}" \
#   -H 'Accept: application/vnd.github.v3+json' \
#   $QUERY_URL)
# fi
# fi
# WITH_DELETE=1
# request_url=actions/runs/$ID/jobs
# QUERY_BASE=actions/runs/$ID/jobs
# QUERY_BASE=actions/jobs/$ID

# QUERY_BASE=actions/workflows
# QUERY_BASE=actions/workflows/$ID
# QUERY_BASE=topics
# WITH_AUTH=0
# QUERY_BASE=contributors
# SEARCH_FIELD=login
# depts+=(REPO)
# QUERY_BASE=contributors
# QUERY_BASE=collaborators/$USER/permission
# WITH_AUTH=0

# QUERY_URL=""
# field_label=""
# WITH_AUTH=1
# WITH_SEARCH=1
# TOPIC=repos
# SEARCH_STRING=''

# if [ $exit_code -ne 0 ]; then
#   write_error "request exit_code != 0... got $results[0]\n"
#   before_exit
#   exit $results[0]
# fi
# printf "\n\n%s\n\n" ${results[@]}
# printf "exit_code: %d\n" ${results[0]}
      # echo "$request_url"
      # printf "request_url: %s\n" $request_url
      # printf "request_url: %s\n" $request_url
      # args=(--url)
      # args+=($request_url)
      # args+=(--id)
      # args+=($ID)
      # args+=(--repo)
      # args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
      # args+=(--owner)
      # args+=($GITHUB_REPOSITORY_OWNER)
      # exit
      # results=($(args ${args[@]}))
      # printf "exit_code: %d\n" ${results[0]}
      # echo "${results[@]:1}" | jq
      # before_exit
      # exit 0
# printf -v eval_str "echo \"$dep\"\n"
# printf "\t%s\n" $eval_str
# dep_val=$(eval $eval_str)
# printf "\n\tdep_val: %s\n" $dep_val
# eval "echo \$$dep"
# val=$(eval "echo \$${dep}")
# echo "$request_url" | sed s/$dep/$(eval "echo \"\$$dep\"")/
# request_url=$(echo "$request_url" | sed s/$dep/$(eval "echo \"\$$dep\"")/)

# [ -z "$QUERY_URL" ] && QUERY_URL="$GITHUB_API_URL/$TOPIC/$OWNER/$REPO/$QUERY_BASE"
# [ ! -z "$SEARCH_FIELD" ] && WITH_SEARCH=0
# if [ $WITH_SEARCH -eq 0 ] && [ -z "$SEARCH_STRING" ]; then
#   # SEARCH_STRING='map(.[$field_name]) | join(",")'
#   # SEARCH_STRING='map(.[$field_name])'
#   SEARCH_STRING='.[] | .[$field_name]'
# fi
# printf "QUERY_URL=%s\n" "$QUERY_URL"
# response=""
# output=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g' | tr '\r\n' ' ')
# request_status=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
# request_status=$((${request_status} + 0))
# [ $request_status -eq 200 ] && request_status=0
# [ $request_status -eq 204 ] && request_status=0
# if [[ "$request_status" =~ ^4[[:digit:]]* ]]; then
#   printf "%s" "$response" | jq -r '.message'
#   return 2
# fi
# printf "%s" "$output" | jq
# printf "REQUEST_STATUS=%d\n" $request_status
# if [ ! -z "$SEARCH_STRING" ]; then
#   result=($(echo $output | jq --arg field_name "$SEARCH_FIELD" -r "$SEARCH_STRING"))
#   if [ ! -z "$field_label" ]; then
#     write_result_map "$(join_by , $(printf "%s\n" ${result[@]} | sed 's/=.*//'))" $1 $field_label
#   else
#     write_result_set "$(join_by , $(printf "%s\n" ${result[@]} | sed 's/=.*//'))" $1
#   fi
# fi



# [ $HAS_TEMPLATE -ne 0 ] && echo "NO TEMPLATE SPECIFIED" && exit 1
# [ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
# [ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
# [ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
# [ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
# [ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
# [ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
# OWNER="$GITHUB_REPOSITORY_OWNER"
# REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')
# kv_map=()

# [ $debug_mode -eq 0 ] && printf "DEPTS:\n\t%s\n" ${depts[@]}
