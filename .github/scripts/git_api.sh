#!/bin/sh

WITH_AUTH=1
WITH_SEARCH=1
[ ! -z "$1" ] && template="$1"
TOPIC=repos

echo "template=$template"

case $template in
  artifacts)
    QUERY_BASE=actions/artifacts
    ;;
  collaborators)
    QUERY_BASE=collaborators
    WITH_AUTH=0
    ;;
  collaborator_usernames)
    SEARCH_FIELD=login
    QUERY_BASE=collaborators
    WITH_AUTH=0
    ;;
  is_collaborator)
    QUERY_BASE=collaborators/$USER
    WITH_AUTH=0
    # /repos/{owner}/{repo}/collaborators/{username}
    ;;
  labels)
    SEARCH_FIELD=name
    QUERY_BASE=labels
    WITH_SEARCH=0
    ;;
  pull_request)
    QUERY_BASE=pulls/ID
    ;;
  pull_requests)
    QUERY_BASE=pulls
    ;;
  pull_request_commits)
    QUERY_BASE=pulls/ID/commits
    ;;
  pull_request_files)
    QUERY_BASE=pulls/ID/files
    ;;
  pull_request_merged)
    QUERY_BASE=pulls/ID/merge
    ;;
  releases)
    QUERY_BASE=releases
    ;;
  release)
    QUERY_BASE=releases/$ID
    ;;
  release_assets)
    QUERY_BASE=releases/$ID/assets
    ;;
  release_latest)
    QUERY_BASE=releases/latest
    ;;
  release_latest_id)
    QUERY_BASE=releases/latest
    SEARCH_FIELD=id
    SEARCH_STRING='.[$field_name]'
    ;;
  release_latest_tag)
    QUERY_BASE=releases/latest
    SEARCH_FIELD=tag_name
    SEARCH_STRING='.[$field_name]'
    ;;
  tagged)
    QUERY_BASE=releases/tags/$TAG
    ;;
  repo_branches)
    QUERY_BASE=branches
    # WITH_AUTH=0
    ;;
  repo_user_permissions)
    QUERY_BASE=collaborators/$USER/permission
    WITH_AUTH=0
    ;;
  repo_contributors)
    QUERY_BASE=contributors
    # WITH_AUTH=0
    ;;
  repo_languages)
    QUERY_BASE=languages
    WITH_AUTH=0
    ;;
  repo_tags)
    QUERY_BASE=tags
    WITH_AUTH=0
    ;;
  repo_teams)
    QUERY_BASE=teams
    WITH_AUTH=0
    ;;
  repo_topics)
    QUERY_BASE=topics
    WITH_AUTH=0
    ;;
  repo_workflow)
    QUERY_BASE=actions/workflows/$ID
    # GET /repos/{owner}/{repo}/actions/workflows/{workflow_id}
    ;;
  repo_workflow_ids)
    QUERY_BASE=actions/workflows
    SEARCH_FIELD=id
    SEARCH_STRING='.workflows | map(.[$field_name]) | join(",")'
    ;;
  repo_workflow_names)
    QUERY_BASE=actions/workflows
    SEARCH_FIELD=name
    SEARCH_STRING='.workflows | map(.[$field_name]) | join(",")'
    ;;
  repo_workflows)
    QUERY_BASE=actions/workflows
    ;;
  repo_workflow_run)
    QUERY_BASE=actions/runs/$ID
    # /repos/{owner}/{repo}/actions/runs/{run_id}
    ;;
  repo_workflow_runs)
    QUERY_BASE=actions/runs
    ;;
  repo_workflow_run_ids)
    QUERY_BASE=actions/runs
    SEARCH_FIELD=id
    SEARCH_STRING='.workflow_runs | map(.[$field_name]) | join(",")'
    ;;
  repo_workflow_usage)
    QUERY_BASE=actions/workflows/$ID/timing
    # GET /repos/{owner}/{repo}/actions/workflows/{workflow_id}/timing
    ;;
  workflow_runs)
    QUERY_BASE=actions/workflows/$ID/runs
    # /repos/{owner}/{repo}/actions/workflows/{workflow_id}/runs
    ;;
  workflow_run_job)
    QUERY_BASE=actions/jobs/$ID
    # /repos/{owner}/{repo}/actions/jobs/{job_id}
    ;;
  workflow_run_jobs)
    QUERY_BASE=actions/runs/$ID/jobs
    # repos/tatehanawalt/homebrew-devtools/actions/runs/874204741/jobs
    ;;
  user_repos)
    TOPIC=users
    QUERY_BASE=repos
    QUERY_URL="https://api.github.com/$TOPIC/$USER/$QUERY_BASE"
    WITH_AUTH=0
esac

# Aggregate values
if [ -z "$QUERY_URL" ]; then
  QUERY_URL="https://api.github.com/$TOPIC/$OWNER/$REPO/$QUERY_BASE"
fi
echo "QUERY_URL=$QUERY_URL"
if [ ! -z "$SEARCH_FIELD" ]; then
  echo "ENABLED_SEARCH_FROM_FIELD=$SEARCH_FIELD"
  WITH_SEARCH=0
fi
if [ $WITH_SEARCH -eq 0 ]; then
  if [ -z "$SEARCH_STRING" ]; then
    SEARCH_STRING='map(.[$field_name]) | join(",")'
  fi
  echo "SEARCH_STRING=$SEARCH_STRING"
fi
if [ -z "$output" ]; then
  if [ $WITH_AUTH -eq 0 ]; then
    output=$(curl \
      -H "Authorization: token $GITHUB_AUTH_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      $QUERY_URL)
  else
    output=$(curl -H "Accept: application/vnd.github.v3+json" $QUERY_URL)
  fi
  output_exit_code=$?
  echo "OUTPUT:"
  echo "EXIT_CODE=$output_exit_code"
fi
echo "$output" | jq
if [ ! -z "$SEARCH_STRING" ]; then
  # Search the response json
  ESCAPED=$(echo $output | jq --arg field_name $SEARCH_FIELD -r "$SEARCH_STRING" )
  jq_exit_code=$?
  echo "SEARCHED:"
  echo "$ESCAPED"


  ESCAPED="${ESCAPED//'%'/'%25'}"
  ESCAPED="${ESCAPED//$'\n'/'%0A'}"
  ESCAPED="${ESCAPED//$'\r'/'%0D'}"
  echo "ESCAPED:"
  echo "EXIT_CODE=$jq_exit_code"
  printf "%s" "$ESCAPED"
  echo
fi
echo "::set-output name=RESULT::${ESCAPED}"



# OWNER=tatehanawalt
# USER=tatehanawalt
# TAG=0.0.0
# GITHUB_AUTH_TOKEN=API_AUTH_TOKEN
# REPOS:
# REPO=homebrew-devtools
# REPO=th_sys
# OWNER != USER... OWNER can be the organization
# Workflow Run Ids:
# WORKFLOW_RUN_IDS=876490197,876480259,876269471,876267905,876265708,876261276,876256013,876253650,876230652,876226875,876225737,876222043,876217806,876214470,876201357,876181959,876169169,876131344,876128796,876124463,876109125,876056503,876056294,876049383,876048116,876043023,876033915,876030290,875949473,875942274
# ID=876490197
# DELETE /repos/{owner}/{repo}/actions/runs/{run_id}
# WORKFLOW_RUN_IDS=$(echo "$WORKFLOW_RUN_IDS" | sed 's/,/\n/g')
# for id in $WORKFLOW_RUN_IDS; do
#   printf "id: %s\n"  $id
#   curl \
#     -X DELETE \
#     -H "Authorization: token $GITHUB_AUTH_TOKEN" \
#     -H "Accept: application/vnd.github.v3+json" \
#     https://api.github.com/repos/octocat/hello-world/actions/runs/$id
#   break
# done
