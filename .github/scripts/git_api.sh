#!/bin/sh

# TESTING:
# export GITHUB_API_URL=https://api.github.com
# export GITHUB_REPOSITORY="tatehanawalt/homebrew-devtools"
# export GITHUB_REPOSITORY_OWNER=tatehanawalt
# export GITHUB_HEAD_REF=diff_files_Action
# export GITHUB_BASE_REF=main
# export GITHUB_API_URL=https://api.github.com && export GITHUB_REPO=tatehanawalt/homebrew-devtools && export GITHUB_REPOSITORY_OWNER=tatehanawalt && export GITHUB_HEAD_REF=diff_files_Action && export GITHUB_BASE_REF=main
# BASE - base branch
# HEAD - head branch
# REPO - repository
# OWNER - repo owner

WITH_AUTH=1
WITH_SEARCH=1
TOPIC=repos

in_log=0
in_ci=1
[ "$CI" = "true" ] && in_ci=0 # IF RUN BY CI vs Locally

# This function starts a git actions log group. Call with 0 args to end a log
# group without starting a new one
log() {
  if [ $in_log -ne 0 ]; then
    if [ $in_ci -eq 0 ]; then
      echo "::endgroup::";
    fi
    in_log=0
  fi
  # Do we need to start a group?
  if [ ! -z "$1" ]; then
    if [ $in_ci -eq 0 ]; then
      echo "::group::$1";
    else
      echo "$1:"
    fi
    in_log=1
  fi
}



[ ! -z "$1" ] && template="$1"
if [ -z "$template" ]; then
  echo "NO TEMPLATE SPECIFIED"
  exit 1
fi

[ -z "$GITHUB_API_URL" ] && GITHUB_API_URL="https://api.github.com"
[ ! -z "$GITHUB_REPOSITORY_OWNER" ] && OWNER=$GITHUB_REPOSITORY_OWNER
[ ! -z "$GITHUB_REPOSITORY" ] && REPO=$(echo "$GITHUB_REPOSITORY" | sed 's/.*\///')
[ ! -z "$GITHUB_HEAD_REF" ] && HEAD=$GITHUB_HEAD_REF
[ ! -z "$GITHUB_BASE_REF" ] && BASE=$GITHUB_BASE_REF

log "FIELDS"
echo "CI=$in_ci"
echo "OWNER=$OWNER"
echo "REPO=$REPO"
echo "HEAD=$HEAD"
echo "BASE=$BASE"
echo "USER=$USER"
echo "TAG=$TAG"
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
    ;;

  workflow_runs)
    QUERY_BASE=actions/workflows/$ID/runs
    ;;
  workflow_run_job)
    QUERY_BASE=actions/jobs/$ID
    ;;
  workflow_run_jobs)
    QUERY_BASE=actions/runs/$ID/jobs
    # repos/tatehanawalt/homebrew-devtools/actions/runs/874204741/jobs
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
esac

# Aggregate values
if [ -z "$QUERY_URL" ]; then
  QUERY_URL="$GITHUB_API_URL/$TOPIC/$OWNER/$REPO/$QUERY_BASE"
fi
if [ ! -z "$SEARCH_FIELD" ]; then
  WITH_SEARCH=0
fi
if [ $WITH_SEARCH -eq 0 ]; then
  if [ -z "$SEARCH_STRING" ]; then
    SEARCH_STRING='map(.[$field_name]) | join(",")'
  fi
fi

echo "QUERY_BASE=$QUERY_BASE"
echo "TOPIC=$TOPIC"
echo "WITH_SEARCH=$WITH_SEARCH"
echo "WITH_AUTH=$WITH_AUTH"
echo "QUERY_URL=$QUERY_URL"
echo "SEARCH_FIELD=$SEARCH_FIELD"
echo "SEARCH_STRING=$SEARCH_STRING"

if [ -z "$output" ]; then
  if [ $WITH_AUTH -eq 0 ]; then
    output=$(curl \
      -s \
      -H "Authorization: token $GITHUB_AUTH_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      $QUERY_URL)
  else
    output=$(curl -s -H "Accept: application/vnd.github.v3+json" $QUERY_URL)
  fi
  output_exit_code=$?
  echo "OUTPUT:"
  echo "EXIT_CODE=$output_exit_code"
fi

log RESPONSE
echo "$output" | jq

log SEARCH
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

log

echo "::set-output name=RESULT::${ESCAPED}"

exit 0


# USER=tatehanawalt
# TAG=0.0.0
# GITHUB_AUTH_TOKEN=API_AUTH_TOKEN
