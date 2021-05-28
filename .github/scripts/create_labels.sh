#!/bin/bash

. "$(dirname $0)/helpers.sh"

DEFAULT_LABELS='[{"name":":beer:","description":"Somehow related to homebrew","color":"F28E1C"},{"name":":bug:","description":"Literally a bug","color":"ffd438"},{"name":":alien:","description":"Something is unknown","color":"ffd438"},{"name":":robot:","description":"Robots are working on it!","color":"814fff"},{"name":":zap:","description":"A robot fixed something","color":"24a0ff"}]'


# DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq '. | . + [{"name": "demo1", "description": "demo description", "color": "F28E1C"}]')
# DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq --arg name "$name" '. | . + [{"name": "demo1", "description": "demo description", "color": "F28E1C"}]')


printf  "\n\n Called CREATE LABELS \n\n"
printf "%s\n" "${ADD_LABELS[@]}"
# CURRENT_LABELS

# ADD_LABELS
add_labels=($(printf "%s\n" "${ADD_LABELS[@]}" | tr , '\n' | tr [[:upper:]] [[:lower:]] | sort -u))
for label in ${add_labels[@]}; do
  printf "adding: %s\n" $label
  DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq --arg name "$label" '. | . + [{"name": $name}]')
done

for row in $(echo "${DEFAULT_LABELS}" | jq -r '.[] | @base64'); do
  _jq() { echo ${row} | base64 --decode | jq -r ${1}; }
  echo "$(_jq '.name') $(_jq '.color') $(_jq '.description')"

  continue

  data=$(jq -n \
    --arg name "$(_jq '.name')" \
    --arg color "$(_jq '.color')" \
    --arg description "$(_jq '.description')" \
    '{"name": $name, "color": $color, "description": $description}')
  data=$(echo "$data" |  jq '. as $a| [keys[]| select($a[.]!="")| {(.): $a[.]}]| add')
  IFS=$'\n'
  args=(--url)
  args+=('repos/$OWNER/$REPO/labels')
  args+=(--repo)
  args+=($(printf %s $GITHUB_REPOSITORY | sed 's/.*\///'))
  args+=(--owner)
  args+=($GITHUB_REPOSITORY_OWNER)
  args+=(--json-body)
  args+=($(printf "%s" $data))
  results=($(git_post ${args[@]}))

  printf "\nexit_code: %d\n\n%s\n" ${results[0]}
  echo "${results[@]:1}" | jq
  printf "\n"
done










# for label in "${add_labels[@]}"; do
#   add=$(contains "$label" "${current_labels[@]}")
#   exit_code=$?
#   [ $exit_code -eq 0 ] && continue
#   create_labels+=( "$label" )
# done
# write_result_set $(join_by , "${create_labels[@]}") create_labels
# for label in ${create_labels[@]}; do
#   result=$(create_label "$label")
#   exit_status=$?
#   echo $result | jq -r | jq
# done
# before_exit
# exit 0
