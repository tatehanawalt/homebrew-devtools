#!/bin/bash

debug_mode=1
write_out=1
IFS=$'\n'
max_field_len=0
NC='\033[0m' # No Color
Red='\033[0;31m'
clr=$(printf %b $Red)
nclr=$(printf %b $NC)
# echo -e "\033[38;5;208mpeach\033[0;00m"
ferpf_color=$(echo -e "\033[38;5;50m")
alert_color=$(echo -e "\033[38;5;255m")

# printf "mypath:  %s\n" "$0"
# printf "mypath:  %s\n"
#  SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# for ((i=0; i<=256; i++)); do nc=$(clfn $i) ferpf "$i\n"; done

clfn() {
  echo -e "\033[38;5;$1m"
}

IN_LOG=0
IN_CI=1
[ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally
HELPERS_LOG_TOPICS=()

# env var template specified
HAS_TEMPLATE=1
if [ -z "$template" ]; then
  [ ! -z "$1" ] && template="$1"
  if [ ! -z "$template" ]; then
    HAS_TEMPLATE=0
  fi
else
  HAS_TEMPLATE=0
fi

show_colors() {
  echo -en "\n   +  "
  for i in {0..35}; do
  printf "%2b " $i
  done
  printf "\n\n %3b  " 0
  for i in {0..15}; do
  echo -en "\033[48;5;${i}m  \033[m "
  done
  #for i in 16 52 88 124 160 196 232; do
  for i in {0..6}; do
  let "i = i*36 +16"
  printf "\n\n %3b  " $i
  for j in {0..35}; do
  let "val = i+j"
  echo -en "\033[48;5;${val}m  \033[m "
  done
  done
  echo -e "\n"
  exit 0
}


ferpf() {
  # [ -z "$nc" ] && printf "%b" $ferpf_color
  [ -z "$nc" ] && printf "%b" $ferpf_color || printf "%b" $nc
  printf $* 1>&2
  printf "%b" $nclr
}

# Call before exitiing mainly for summarizing results and activity
before_exit() {
  [ -z "$HELPERS_LOG_TOPICS" ] && return
  write_result_set "$(join_by , ${HELPERS_LOG_TOPICS[@]})" outputs
  log
}

# Shared github api helper method
git_req() {
  positional=()
  args=()
  req_url=""
  while [[ $# -gt 0 ]];
  do
  key="$1"
  shift
  case $key in
    --auth)
      # TODO:: "Authorization: token $GITHUB_AUTH_TOKEN"
      write_error "auth not implemented in git_Req\n" && exit 1
      ;;
    --id)
      req_url=$(echo "$req_url" | sed s/{id}/$1/)
      ;;
    --json-body)
      args+=(-d)
      args+=("$1")
      ;;
    --labels_csv)
      labels=("$(echo -e $1 | tr , '\n')")
      json_data=$(printf "%s" "${labels[@]}" | jq -R . | jq -s .)
      args+=(-d)
      args+=("$json_data")
      ;;
    --method)
      args+=(-X)
      args+=($1)
      ;;
    --owner)
      req_url=$(echo "$req_url" | sed s/{owner}/$1/)
      ;;
    --repo)
      req_url=$(echo "$req_url" | sed s/{repo}/$1/)
      ;;
    --url)
      [[ "$1" =~ ^/ ]] && write_error "git_req url invalid format. url must not start witha /. url=${1}" exit 1
      [ ! -z "$req_url" ] && write_error "Attempted to set req_url twice. this can only be done once." && exit 1
      req_url="$1"
      ;;
    --user)
      req_url=$(echo "$req_url" | sed s/{user}/$1/)
      ;;
    *)
      positional+=("$key")
      continue
      ;;
  esac
  shift
  done
  args+=( -s -w "HTTPSTATUS:%{http_code}" )
  # add an auth token
  if [ ! -z "$GITHUB_AUTH_TOKEN" ]; then
    args+=( -H "Authorization: token $GITHUB_AUTH_TOKEN" )
  fi
  args+=( -H "Accept: application/vnd.github.v3+json" )
  [ $debug_mode -eq 0 ] && printf "request path: %s\n" ${req_url}
  args+=("https://api.github.com/$req_url")
  if [ $debug_mode -eq 0 ]; then
    printf "\nargs:\n"
    printf "\t%s\n" ${args[@]}
  fi
  response=$(curl "${args[@]}")
  result=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g' | tr '\r\n' ' ')
  request_status=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  results=($request_status)
  results+=($result)
  printf "%s$IFS" ${results[@]}
}

# CSV set helpers
for_csv() {
  IFS=$'\n'
  for field in $(echo $1 | tr ',' '\n'); do
    $2 $field
  done
}
csv_max_length() {
  IFS=$'\n'
  max_field_len=0
  for field in $(printf $1 | tr ',' '\n'); do
    [ ${#field} -gt $max_field_len ] && max_field_len=$((${#field} + 1))
  done
  echo "$max_field_len"
}
join_by () {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}" | sed "s/ $d/$d/g"
    #| sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
    #printf %s "$f" "${@/#/$d}" | sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
  fi
}
contains() {
  IFS=$'\n'
  check=$1
  shift
  for key in $@; do
    if [[ "$check" == "$key" ]]; then
      return 0
    fi
  done
  return 1
}


get_prefix() {
  printf "\t"
}
write_error() {
  echo "::error::$1"
  printf "\n%b$1%b\n\n" "${Red}" "${NC}"
}
log() {
  [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally
  if [ $IN_LOG -ne 0 ]; then
    [ $IN_CI -eq 0 ] && echo "::endgroup::"
  fi
  IN_LOG=0
  if [ ! -z "$1" ]; then
    group=$(echo $1 | tr [[:lower:]] [[:upper:]])
    [ $IN_CI -eq 0 ] && echo "::group::$group"
    [ $IN_CI -eq 1 ] && printf "${Blue}$group:${NC}\n"
    IN_LOG=1
  fi
  return 0
}
log_result_set() {
  printf "$(get_prefix)%s\n" $(echo -e $1 | tr ',' '\n')
}


command_log_which() {
  printf "%s\t%s\n" $1 "$(which $1)"
  printf "%s\n" "$2" | sed "s/^.*divider-bin-\([0-9.]*\).*/\1/"
}
write_result_set() {
  IFS=$'\n'
  result=$(echo -e "$1" | sed 's/"//g')
  [ -z "$result" ] && return 1
  key=$2
  [ -z "$key" ] && key="result"
  key=$(echo $key | tr [[:lower:]] [[:upper:]])
  log $key
  log_result_set "$result" "$key"
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  printf "$key='$result'\n"
  [ $IN_CI -eq 0 ] && echo "::set-output name=$key::$(echo -e $result)"
  HELPERS_LOG_TOPICS+=($key)
}


print_field() {
  printf "%s=$(eval "echo \"\$$1\"")\n" $1
}
print_field_table() {
  IFS=$'\n'
  field_val=$(eval "echo \"\$$1\"" | tr ',' '\n' | sed 's/^[[:space:]]*//g' | sed '/^$/d' | sed 's/=/=\n/')
  field_val=($(echo "$field_val"))
  local_prefix=""
  printf "\t%-${max_field_len}s" "$1:"
  [ -z "$field_val" ] && echo && return
  [ ${#field_val[@]} -gt 1 ] && echo && local_prefix="$(get_prefix)   - "
  # printf "$local_prefix%s\n" ${field_val[@]};
  for field in "${field_val[@]}"; do
    lbl_clr=''
    if [[ "$field" =~ .*\=.* ]]; then
      lbl_clr=$Yellow
      field=$(echo $field | tr [[:lower:]] [[:upper:]] | sed "s/^/$clr/" | sed "s/=/=$nclr/" )
      # field=$(echo $field | sed "s/\=/$( printf %b ${NC} )\=/ )")
      # field=$(echo $field | sed s/$/$(printf %b $NC)$/)
    fi
    printf "$local_prefix%s\n" $field
  done
  # printf "$local_prefix%s\n" ${field_val[@]};
}
default_labels() {
  cat $(dirname $0)/default_labels.json
  # printf "%s" '[{"name":":beer:","description":"Somehow related to homebrew","color":"F28E1C"},{"name":":bug:","description":"Literally a bug","color":"ffd438"},{"name":":alien:","description":"Something is unknown","color":"ffd438"},{"name":":robot:","description":"Robots are working on it!","color":"814fff"},{"name":":zap:","description":"A robot fixed something","color":"24a0ff"}]'
  # _jq() { echo ${row} | base64 --decode | jq -r ${1}; }
  # for row in $(echo "${DEFAULT_LABELS}" | jq -r '.[] | @base64'); do
  #DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq --arg name "$label" --arg color "F28E1C" --arg description "placeholder" '. | . + [{"name": $name, "color": $color, "description": $description}]')
  # DEFAULT_LABELS='[{"name":":beer:","description":"Somehow related to homebrew","color":"F28E1C"},{"name":":bug:","description":"Literally a bug","color":"ffd438"},{"name":":alien:","description":"Something is unknown","color":"ffd438"},{"name":":robot:","description":"Robots are working on it!","color":"814fff"},{"name":":zap:","description":"A robot fixed something","color":"24a0ff"}]'
  # DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq '. | . + [{"name": "demo1", "description": "demo description", "color": "F28E1C"}]')
  # DEFAULT_LABELS=$(echo $DEFAULT_LABELS | jq --arg name "$name" '. | . + [{"name": "demo1", "description": "demo description", "color": "F28E1C"}]')
  # CURRENT_LABELS
}
