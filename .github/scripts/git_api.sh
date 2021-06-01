#!/bin/bash

my_path="$GITHUB_WORKSPACE/.github/scripts/git_api.sh"
[ "$CI" != "true" ] && my_path=$(readlink $0)
. $(dirname $my_path)/helpers.sh

usage() {
  ferpf "giit_api.sh usage:\n"
  # Generate usage by running the search_file function against the path
  # to this file
}
run_input() {
  args=()          # args forwarded to the git api helper method
  request_url=''   # url request path
  search_string='' # a jq search expression for successful response data

  if [ $debug_mode -eq 0 ]; then
    ferpf "run_input:\n"
    ferpf "%s\n" ${@}
  fi

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
    help)
      search_file $my_path
      return 1
      ;;
    is_collaborator)
      request_url='repos/{owner}/{repo}/collaborators/{user}'
      args+=(--auth)
      ;;
    labels)
      request_url='repos/{owner}/{repo}/labels'
      ;;
    label_names)
      request_url='repos/{owner}/{repo}/labels'
      search_string='. | map(.name) | join (",")'
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
    pull_requests)
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
    repo_branches)
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
      request_url='repos/{owner}/{repo}/tags'
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
      # field_val=$NAME
      write_error "todo - fix name dependency"
      exit 1
      # search_string='.workflows | .[] | select(.name == $field_name) | .id'
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
      search_string='[.workflow_runs[] | select(.status == "completed")] | map(.id) | join(",")'
      ;;
    repo_workflow_usage)
      request_url='repos/{owner}/{repo}/workflows/{id}/timing'
      ;;
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
      request_url='repos/{owner}/{repo}/actions/workflows/{id}/runs'
      # SEARCH_STRING='.workflow_runs | map(.run_number) | join(",")'
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
    user_repo_names)
      request_url='users/{user}/repos'
      search_string='.[] | .name'
      ;;
    *)
      write_error "$(basename $0) target $1 not recognized - line $LINENO"
      exit 1
      ;;
  esac
  args+=(--url)
  args+=($request_url)

  depts=($(echo "$request_url" | grep -o '{[[:alpha:]]*}' | grep -o '[^{][[:alpha:]]*[^}]'))
  for dep in ${depts[@]}; do
    case $dep in
      'owner') args+=(--owner $GITHUB_REPOSITORY_OWNER);;
      'repo') args+=(--repo $(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'));;
      'user') args+=(--user tatehanawalt);;
      *)
        write_error "unrecognized dependency $dep\n"
        return 1
        ;;
    esac
  done

  if [ $debug_mode -eq 0 ]; then
    ferpf "args:\n"
    IFS=$'\n'
    ferpf " • %s\n" ${args[@]}
    ferpf "\n"
  fi

  results=($(git_req ${args[@]}))
  exit_code=$(echo "${results[0]}")
  response_body="${results[@]:1}"

  if [ ! -z "$search_string" ]; then
    response_body=$(echo "$response_body" | jq --arg field_name "$field_val" -r "$search_string")
  fi

  echo "$response_body"
}

cmds=($(echo "$template" | tr ',' '\n'))
for cmd in ${cmds[@]}; do
  run_input $cmd
done

exit 0

run_input $1

# return $exit_code
# return $response_body
# exit_code=0
# if in_ci; then
#   for cmd in $(echo "$template" | tr ',' '\n'); do
#     ferpf "command: %s\n" ${cmd}
#     results=($(run_input $cmd))
#     echo $results
#     echo "${results[@]:1}"
#   done
# else
#   results=($(run_input $1))
#   exit_code=$?
#   if [ $exit_code -eq 0 ]; then
#     exit_code=$results
#     echo "${results[@]:1}" | jq
#   else
#     printf "%s\n" "${results[@]}"
#   fi
# fi
# before_exit
# exit $exit_code
# git_req ${args[@]}
# echo "${results[0]}"
# return 1
# exit_code=${results[0]}
# echo $exit_code
# if [ ! -z "$search_string" ]; then
  # echo "${results[@]:1}" | jq --arg field_name "$field_val" -r $search_string
# else
  # echo "${results[@]:1}" | jq
# fi
