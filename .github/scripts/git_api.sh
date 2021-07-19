#!/bin/bash

# git_api can be invoked directly to retrieve metadata from git through the
# git api

[ -z "$TEMPLATE" ] && [ ! -z "$1" ] && TEMPLATE="$1" && shift
[ -z "$TEMPLATE" ] && write_error "\$TEMPLATE undefined - line $LINENO" && exit 1

my_path=$0
. "$(dirname $my_path)/helpers.sh"

function usage() {
  ferpf "git_api.sh usage:\n"
  # Generate usage by running the search_file function against the path
  # to this file
}
function exec_template() {
  args=()          # args forwarded to the git api helper method
  request_url=''   # url request path
  search_string='' # a jq search expression for successful response data
  can_exec=0

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
      write_error "todo - specify search string for .labels field - line $LINENO"
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
      write_error "todo - specify search string for .id field - line $LINENO"
      exit 1
      ;;
    release_latest_tag)
      request_url='repos/{owner}/{repo}/releases/latest'
      write_error "todo - specify search string for .tag_name field - line $LINENO"
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
      write_error "todo - specify search string for .name field - line $LINENO"
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
      write_error "todo - fix name dependency - line $LINENO"
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
      'owner')
        if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
          can_exec=1
          write_error "GITHUB_REPOSITORY_OWNER not set in git_api - line $LINENO"
        fi
        args+=(--owner $GITHUB_REPOSITORY_OWNER)
        ;;
      'repo')
        if [ -z "$GITHUB_REPOSITORY" ]; then
          can_exec=1
          write_error "GITHUB_REPOSITORY not set in git_api - line $LINENO"
        fi
        args+=(--repo $(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
        ;;
      'user')
        args+=(--user tatehanawalt)
        ;;
      'id')
        args+=(--id $ID)
        ;;
      *)
        write_error "unrecognized dependency $dep - line $LINENO"
        return 1
        ;;
    esac
  done
  [ $can_exec -ne 0 ] && write_error "can_exec -ne 0 - line $LINENO" && exit 1
  results=$(git_req ${args[@]})
  [ ! -z "$search_string" ] && results=$(echo "$results" | jq --arg field_name "$field_val" -r "$search_string")
  echo $results
  write_result_set $results RESULT
}
function for_each_id() {
  id_count=$((id_count + 1))
  ID=$1 exec_template $TEMPLATE
}

id_count=0
for_csv "$ID" for_each_id
[ $id_count -eq 0 ] && exec_template $TEMPLATE

before_exit
