#!/bin/bash

# Requires 'jq' JSON query script

search_field=name

# Query Values
QUERY_TOPIC=repos
QUERY_REPO=homebrew-devtools
QUERY_ORG=tatehanawalt
QUERY_BASE=labels

# Aggregate values
QUERY_URL="https://api.github.com/$QUERY_TOPIC/$QUERY_ORG/$QUERY_REPO/$QUERY_BASE"
output=$(curl -H "Accept: application/vnd.github.v3+json" $QUERY_URL)

# Example output you can use for development and debugging to avoid spamming the
# from the api:
#  output='[
#    {
#      "id": 3009221173,
#      "node_id": "MDU6TGFiZWwzMDA5MjIxMTcz",
#      "url": "https://api.github.com/repos/tatehanawalt/homebrew-devtools/labels/documentation",
#      "name": "documentation",
#      "color": "0075ca",
#      "default": true,
#      "description": "Improvements or additions to documentation"
#    },
#    {
#      "id": 3009221173,
#      "node_id": "MDU6TGFiZWwzMDA5MjIxMTcz",
#      "url": "https://api.github.com/repos/tatehanawalt/homebrew-devtools/labels/documentation",
#      "name": "sample space",
#      "color": "0075ca",
#      "default": true,
#      "description": "Improvements or additions to documentation"
#    }
#  ]'

echo "OUTPUT:"
echo "$output"

RESULT=$(echo $output | jq --arg field_name $search_field -r 'map(.[$field_name]) | join(",")')

echo "RESULT:"
echo "$RESULT"

echo "::set-output name=RESULT::$RESULT"
