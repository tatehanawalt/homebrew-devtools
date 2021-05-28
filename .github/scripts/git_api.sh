#!/bin/bash
# Setup the default parameters

. "$(dirname $0)/helpers.sh"

[ $HAS_TEMPLATE -ne 0 ] && echo "NO TEMPLATE SPECIFIED" && exit 1

WITH_AUTH=1
WITH_SEARCH=1
WITH_DELETE=1
TOPIC=repos
request_status=0

[ -z "$GITHUB_API_URL" ]          && GITHUB_API_URL="https://api.github.com"
[ -z "$GITHUB_BASE_REF" ]         && GITHUB_BASE_REF="main"
[ -z "$GITHUB_HEAD_REF" ]         && GITHUB_HEAD_REF="main"
[ -z "$GITHUB_REPOSITORY" ]       && GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
[ -z "$GITHUB_REPOSITORY_OWNER" ] && GITHUB_REPOSITORY_OWNER="tatehanawalt"
[ -z "$GITHUB_WORKSPACE" ]        && GITHUB_WORKSPACE=$(git rev-parse --show-toplevel)
OWNER="$GITHUB_REPOSITORY_OWNER"
REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')

run_input() {
  case $1 in
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
      repo_branche_names
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
      QUERY_BASE=labels
      ;;
    label_names)
      SEARCH_FIELD=name
      QUERY_BASE=labels
      ;;
    label_ids)
      SEARCH_FIELD=id
      QUERY_BASE=labels
      ;;

    pull_request)
      QUERY_BASE=pulls/$ID
      ;;
    pull_request_labels)
      QUERY_BASE=pulls/$ID
      SEARCH_STRING='.labels'
      ;;
    pull_request_label_names)
      QUERY_BASE=pulls/$ID
      SEARCH_STRING='[.labels[]] | map(.name) | join(",")'
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

    pull_requests)
      QUERY_BASE=pulls
      ;;

    release)
      QUERY_BASE=releases/$ID
      ;;
    releases)
      QUERY_BASE=releases
      ;;
    release_assets)
      QUERY_BASE=releases/$ID/assets
      ;;
    release_latest)
      QUERY_BASE=releases/latest
      ;;
    release_latest_id)
      QUERY_BASE=releases/latest
      SEARCH_STRING='.id'
      ;;
    release_latest_tag)
      QUERY_BASE=releases/latest
      SEARCH_STRING='.tag_name'
      ;;

    tagged)
      QUERY_BASE=releases/tags/$TAG
      ;;

    repo_branches)
      QUERY_BASE=branches
      ;;
    repo_branche_names)
      QUERY_BASE=branches
      SEARCH_FIELD=name
      ;;
    repo_user_permissions)
      QUERY_BASE=collaborators/$USER/permission
      WITH_AUTH=0
      ;;

    repo_contributors)
      QUERY_BASE=contributors
      # WITH_AUTH=0
      ;;
    repo_contributor_names)
      QUERY_BASE=contributors
      SEARCH_FIELD=login
      ;;

    repo_languages)
      QUERY_BASE=languages
      ;;
    repo_language_names)
      QUERY_BASE=languages
      SEARCH_STRING='keys | join(",")'
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
      ;;
    repo_workflows)
      QUERY_BASE=actions/workflows
      ;;
    repo_workflow_id)
      QUERY_BASE=actions/workflows
      SEARCH_FIELD=$NAME
      SEARCH_STRING='.workflows | .[] | select(.name == $field_name) | .id'
      ;;
    repo_workflow_ids)
      QUERY_BASE=actions/workflows
      SEARCH_STRING='.workflows | map(.id) | join(",")'
      ;;
    repo_workflow_names)
      QUERY_BASE=actions/workflows
      SEARCH_FIELD=name
      SEARCH_STRING='.workflows | map(.[$field_name]) | join(",")'
      ;;
    repo_workflow_runs)
      QUERY_BASE=actions/runs
      ;;
    repo_workflow_completed_runs)
      QUERY_BASE=actions/runs
      SEARCH_STRING='[.workflow_runs[] | select(.status == "completed")]'
      ;;
    repo_workflow_run_ids)
      QUERY_BASE=actions/runs
      SEARCH_STRING='.workflow_runs | map(.id) | join(",")'
      ;;
    repo_workflow_completed_run_ids)
      QUERY_BASE=actions/runs
      SEARCH_STRING='[.workflow_runs[] | select(.status == "completed")] | map(.id) | join(",")'
      ;;
    repo_workflow_usage)
      QUERY_BASE=actions/workflows/$ID/timing
      ;;

    workflow_runs)
      QUERY_BASE=actions/workflows/$ID/runs
      ;;
    workflow_completed_runs)
      QUERY_BASE=actions/workflows/$ID/runs
      SEARCH_STRING='[.workflow_runs[] | select(.status == "completed")]'
      ;;
    workflow_run_ids)
      QUERY_BASE=actions/workflows/$ID/runs
      SEARCH_STRING='.workflow_runs | map(.id) | join(",")'
      ;;
    workflow_completed_run_ids)
      QUERY_BASE=actions/workflows/$ID/runs
      SEARCH_STRING='[.workflow_runs[] | select(.status == "completed")] | map(.id) | join(",")'
      ;;

    delete_workflow_run)
      WITH_DELETE=0
      QUERY_URL="$GITHUB_API_URL/$TOPIC/$OWNER/$REPO/actions/runs/$ID"
      ;;
    workflow_run_numbers)
      QUERY_BASE=actions/workflows/$ID/runs
      SEARCH_STRING='.workflow_runs | map(.run_number) | join(",")'
      ;;
    workflow_run_job)
      QUERY_BASE=actions/jobs/$ID
      ;;
    workflow_run_jobs)
      QUERY_BASE=actions/runs/$ID/jobs
      ;;

    user_repos)
      TOPIC=users
      QUERY_BASE=repos
      QUERY_URL="$GITHUB_API_URL/$TOPIC/$USER/$QUERY_BASE"
      ;;
    user_repo_names)
      TOPIC=users
      QUERY_BASE=repos
      QUERY_URL="$GITHUB_API_URL/$TOPIC/$USER/$QUERY_BASE"
      SEARCH_FIELD=name
      ;;
    *)
      printf "UNHANDLED TARGET: $1"
      return 1
      ;;
  esac

  [ -z "$QUERY_URL" ] && QUERY_URL="$GITHUB_API_URL/$TOPIC/$OWNER/$REPO/$QUERY_BASE"
  [ ! -z "$SEARCH_FIELD" ] && WITH_SEARCH=0
  [ $WITH_SEARCH -eq 0 ] && [ -z "$SEARCH_STRING" ] && SEARCH_STRING='map(.[$field_name]) | join(",")'

  response=""
  if [ $WITH_DELETE -eq 0 ]; then
    response=$(curl \
      -X DELETE \
      -s \
      -w "HTTPSTATUS:%{http_code}" \
      -H "Authorization: token $GITHUB_AUTH_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      $QUERY_URL)
  else
    if [ $WITH_AUTH -eq 0 ]; then
      response=$(curl \
        -s \
        -w "HTTPSTATUS:%{http_code}" \
        -H "Authorization: token $GITHUB_AUTH_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        $QUERY_URL)
    else
      response=$(curl \
        -s \
        -w "HTTPSTATUS:%{http_code}" \
        -H 'Accept: application/vnd.github.v3+json' \
        $QUERY_URL)
    fi
  fi
  output=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g' | tr '\r\n' ' ')
  request_status=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  request_status=$((${request_status} + 0))
  [ $request_status -eq 200 ] && request_status=0
  [ $request_status -eq 204 ] && request_status=0
  log RESPONSE
  echo $output | jq
  if [ ! -z "$SEARCH_STRING" ]; then
    log SEARCH
    result=$(echo $output | jq --arg field_name "$SEARCH_FIELD" -r "$SEARCH_STRING")
    echo "$result\n"
  fi
  echo "::set-output name=RESULT::${result}"
  log
}

IDS=$(printf "%s" $ID | tr ',' '\n')
lines=$(echo "$IDS" | wc -l)
if [ $lines -le 1 ]; then
  run_input $template
  exit $request_status
fi
for entry in $IDS; do
  ID=$entry
  request_status=0
  run_input $template
  [ $request_status -ne 0 ] && break
done

exit $request_status
