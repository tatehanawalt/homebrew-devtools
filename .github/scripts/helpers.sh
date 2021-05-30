#!/bin/bash

helpers_start_time=$(date +%s)
IFS=$'\n'
silent_mode=1
debug_mode=1

debug() {
  if [ -z "$debug_mode" ];
  then
    return 1
  fi
  if [ $debug_mode -eq 0 ];
  then
    return 0
  fi
  return 1
}
in_ci() {
  [ -z "$CI" ] && return 1
  [ "$CI" = "true" ] && return 0
  return 1
}

# Parse args for silent, debug etc...
for arg in $@; do
  case $arg in
    # Print debug logging
    -d) debug_mode=0;;

    # silent mode - disables output (including debug messages)
    -s)
      silent_mode=0
      eval "exec 2> /dev/null"
      ;;
  esac
done

max_field_len=0

# Specify Colors
noc=$(echo -en '\033[0m')
red=$(echo -en '\033[0;31m')
blue_navy=$(echo -en '\033[38;5;25m')
blue=$(echo -en '\033[38;5;33m')
dark_grey=$(echo -en '\033[38;5;235m')
# Assign colors
alert_color=$(echo -en "\033[38;5;255m")
error_color=$red
log_color=$blue_navy
ferpf_color=$dark_grey
decorate_color=$noc
field_color=$blue

lp=' '
table_indent=''
print_debug_header=1

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

case_signatures() {
  div_bar=$(printf '=%.0s' {1..122} | sed 's/=/-/g' | sed "s/^/$decorate_color/")
  div_wall=$(echo -e "$decorate_color|$ferpf_color")
  function_body=$(sed -n '/^run_input/I,/^}/I{ p;}' $1)
  signatures=$(echo "$function_body" | sed -n '/case \$1 in/I,/esac/I{ s/#.*//; /^[[:space:]]*$/d; /(/d; p;}')
  signatures=$(printf "%s\n" ${signatures[@]} | sed 's/^[[:space:]]*//g' | sed -e '2,$!d' -e '$d')
  methods=($(echo "${signatures[@]}" | \
    grep -o '^.*)' | \
    grep -o '^.*[:alpha:].*[^)]' | \
    awk '{ gsub(/ /,""); print }' | \
    tr -s '')) # don't neeeed the tr but just for good measure

  # This is a csv of the method signatures and the character length of the
  # longest method signature.
  methods_csv=$(join_by , ${methods[@]})
  max_method_signature_width=$(csv_max_length $methods_csv)

  method_paths=()             # the paths added to the api url to make the http request
  max_request_path_width=0    # max width of any path used
  path_fields=()              # fields are essentially parameters embedded in the request path
  path_fields_max_width=0     # max width of field set
  request_methods=()          # The method we use to make the web request (POST, PUT, DELETE, etc...)
  request_method_max_width=0  # max width of any request method
  requires_auth=()            # Does the method body contain the --auth flag

  for ((i=0; i<${#methods[@]}; i++));
  do
    method="${methods[$i]}"
    def=$(sed -n "/[[:space:]]$method)/I,/;;/I{ p;}" $1)
    # Request Path
    request_path=$(echo "$def" | sed '/#/d' | grep -o "request_url.*" | sed 's/^.*=//' | tr -d '"' | tr -d "'")
    method_paths+=("$request_path")
    [ ${#request_path} -gt $max_request_path_width ] && max_request_path_width=${#request_path}
    # fields which are value substitutions from the request path
    fields=$(echo "$request_path" | tr '/' '\n' | grep -o "{.*" | sort)
    field_str=$(printf "%s " $fields | sed 's/ *$//' | tr -d '{' | tr -d '}')
    path_fields+=("${field_str[@]}")
    [ ${#field_str} -gt $path_fields_max_width ] && path_fields_max_width=${#field_str}
    # Request requires auth
    auth_str=$(echo "$def" | grep -o '\-\-auth')
    method_requires_auth=1
    [ ! -z "$auth_str" ] && method_requires_auth=0
    requires_auth+=($method_requires_auth)
    # Request Method
    method_str=$(echo "$def" | grep -o '\-\-method[^)]*' | sed 's/.*method//' | tr -d ' ')
    [ -z "$method_str" ] && printf -v method_str "GET"
    request_methods+=("$method_str")
    [ ${#method_str} -gt $request_method_max_width ] && request_method_max_width=${#method_str}
  done

  ferpf "%s%s\n" "$table_indent" "$div_bar"
  ferpf "%smethods:                    %d\n" "$table_indent" ${#methods[@]}
  ferpf "%smethod_paths:               %d\n" "$table_indent" ${#method_paths[@]}
  ferpf "%spath_fields:                %d\n" "$table_indent" ${#path_fields[@]}
  ferpf "%srequires_auth:              %d\n" "$table_indent" ${#requires_auth[@]}
  ferpf "%srequest_methods:            %d\n" "$table_indent" ${#request_methods[@]}
  ferpf "%s%s\n" "$table_indent" $div_bar
  ferpf "%smax_method_signature_width: %d\n" "$table_indent" $max_method_signature_width
  ferpf "%smax_request_path_width:     %d\n" "$table_indent" $max_request_path_width
  ferpf "%spath_fields_max_width:      %d\n" "$table_indent" $path_fields_max_width
  ferpf "%srequest_method_max_width:   %d\n" "$table_indent" $request_method_max_width

  # First horizontal bar of the table
  ferpf "%s%s\n" "$table_indent" "$div_bar"
  for ((i=0; i<${#methods[@]}; i++)); do
    # Get table column values
    method="${methods[$i]}"
    req_path=${method_paths[$i]}
    path_fields=${path_fields[$i]}
    request_method=${request_methods[$i]}
    # Format table row column values
    printf -v sig_row "%s%-${max_method_signature_width}s%s" "$lp" "$method" "$lp"
    printf -v path_row "%s%-${max_request_path_width}s%s" "$lp" "$req_path" "$lp"
    printf -v fields_row "%s%-${path_fields_max_width}s%s" "$lp" "$path_fields" "$lp"
    printf -v request_method_row "%s%-${request_method_max_width}s%s" "$lp" "$request_method" "$lp"
    # Row substitutions (highlighting)
    path_row=$(echo $path_row | sed "s/}/$ferpf_color}/g" | sed "s/{/{$field_color/g")
    # Table row offset indent (set above, not here)
    ferpf "%s" "$table_indent"
    # Print the actual row
    #ferpf "%s" "$div_wall"          # Table Row Entrypoint
    ferpf "%s" "${sig_row}"          # Method Signature
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "%s" "${path_row}"         # Request Path
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "%s" "$fields_row"         # Fields
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "%s" "$request_method_row" # Request Method
    #ferpf "%s" "$div_wall"          # Vertical Divider
    ferpf "\n"                       # End of row
    # Split the table for readability
    #[ $(($i % 6)) -eq 5 ] && ferpf "%s%s\n" "$lp" "$div_bar"
  done
  # Last horizontal bar in the table
  ferpf "%s%s\n\n" "$table_indent" "$div_bar"
}
search_file() {
  case_signatures $1
}


ferpf() {
  if [ ${#@} -lt 1 ]; then
    echo 1>&2
    return
  fi
  # [ -z "$nc" ] && printf "%b" $ferpf_color
  # printf "%b" $ferpf_color &>/dev/null
  # [ -z "$nc" ] || printf "%b" $nc
  printf $* 1>&2
  #printf $* 1>&2
  # printf "$noc"
}

set_fg() {
  if [ $1 -eq -1 ]; then
    echo -en '\033[0m'
  else
    echo -en "\033[38;5;${1}m"
  fi
}
set_bg() {
  if [ $1 -eq -1 ]; then
    echo -en '\033[0m'
  else
    echo -en "\033[48;5;${1}m"
  fi
}
pallette() {
  for i in {0..255}; do
    i_rem=$(expr $i % 10)
    [ $i_rem -eq 0 ] && printf "$table_indent"
    set_bg $i
    printf "%s\t" "$i"
    set_bg -1
    [ $i_rem -eq 9 ] && echo
  done
  echo -e "\n"
  for i in {0..255}; do
    i_rem=$(expr $i % 10)
    [ $i_rem -eq 0 ] && printf "$table_indent"
    set_fg $i
    printf "%s\t" "$i $@"
    set_fg -1
    [ $i_rem -eq 9 ] && echo
  done
  # printf -v blank " %.0s" {1..${#msg}}
  # echo "width: ${#msg}\n"
  # echo "width: ${#msg}\n"
  # printf -v msg "$index$@"
  # set_fg $i
  # echo -en $msg
  # set_fg -1
  # echo -en $msg
  # set_bg $i
  # set_fg 255
  # echo -en $msg
  # set_fg 0
  # echo -en $msg
  # set_bg -1
  # | fmt -c -w $COLUMNS

  set_fg -1
  set_bg -1
  echo
}
show_colors() {
  echo -en "\n   +  "
  for i in {0..35};
  do
  printf "%2b $i" $i
  done
  printf "\n\n %3b  " 0
  for i in {0..15};
  do
  echo -en "\033[48;5;${i}m $i \033[m "
  done
  #for i in 16 52 88 124 160 196 232; do
  for i in {0..6};
  do
  let "i = i*36 +16"
  printf "\n\n %3b $i " $i
    for j in {0..35};
    do
    let "val = i+j"
    echo -en "\033[48;5;${val}m  \033[m "
    done
  done
  echo -e "\n"
  exit 0
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
      [ -z "$GITHUB_AUTH_TOKEN" ] && write_error "GITHUB_AUTH_TOKEN not set in git_Req\n" && exit 1
      args+=(-H "Authorization: token $GITHUB_AUTH_TOKEN")
      continue
      ;;
    --id)
      req_url=$(echo "$req_url" | sed s/{id}/$1/)
      ;;
    --json-body)
      args+=(-d)
      args+=($1)
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

  args+=( -H "Accept: application/vnd.github.v3+json" )
  [ $debug_mode -eq 0 ] && printf "request path: %s\n" ${req_url}

  args+=("https://api.github.com/$req_url")
  if [ $debug_mode -eq 0 ]; then
    printf "\nargs:\n"
    printf "\t%s\n" ${args[@]}
  fi



  echo "req_url: $req_url"
  echo "args:"
  printf "\t%s\n" ${args[@]}
  echo



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
    [ ${#field} -gt $max_field_len ] && max_field_len=$((${#field}))
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
  echo -en $error_color
  echo "::error::$1"
  echo -en $noc
}
log() {
  debug && printf 'called_from_function: %s\n' "$(caller)"

  # echo -en "$log_color"
  [ -z $in_log ] && in_log=0
  if [ $in_log -ne 0 ]; then
    echo "::endgroup::"
  fi
  in_log=0
  if [ ! -z "$1" ]; then
    group=$(echo $1 | tr [[:lower:]] [[:upper:]])
    echo "::group::${group}"
    in_log=1
  fi
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
  printf "$(get_prefix)%s\n" $(echo -e "$result" | tr ',' '\n')
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  printf "$key='$result'\n"
  in_ci && echo "::set-output name=$key::$(echo -e $result)"
  # [ $IN_CI -eq 0 ] && echo "::set-output name=$key::$(echo -e $result)"
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
      field=$(echo $field | tr [[:lower:]] [[:upper:]] | sed "s/^/$clr/" )
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

if debug; then
  [ $silent_mode -eq 1 ] && echo -en "\033c\n"
  echo -e "DEBUG MODE:" | tr -s ' ' | fmt -c -w $(tput cols) 1>&2
  ferpf "${table_indent}UI text prints to stderr\n" | tr -s ' ' | fmt -c -w $(tput cols)
  ferpf '\tsupress by piping stderr to /dev/null\n' | tr -s ' ' | fmt -c -w $(tput cols)
  ferpf '\t$: git_api 2> /dev/null\n'
  ferpf '\t$: git_api 2> /dev/null\n'
  echo 1>&2
  echo -e "args: ${#@}" 1>&2
  for ((i=0; i<${#@}; i++)); do
    echo -e "  $i - ${!i}" 1>&2
  done
  echo 1>&2
  echo -e "helpers: $0" 1>&2
  echo -e "my_path: $(readlink $0)" 1>&2
  echo -e "helpers_start_time: ${helpers_start_time}" 1>&2
  echo -e "debug_mode=$debug_mode" 1>&2
  echo -e "silent_mode=$silent_mode" 1>&2
  echo 1>&2
  [ $silent_mode -eq 1 ] && pallette 'clr' && echo 1>&2
  write_error "test error"
  echo 1>&2
  log sample_log
  ferpf
  search_file $my_path
  ferpf
fi


# IN_CI=1
# [ "$CI" = "true" ] && IN_CI=0 # IF RUN BY CI vs Locally
#    --labels_csv)
#      labels=("$(echo -e $1 | tr , '\n')")
#      json_data=$(printf "%s" "${labels[@]}" | jq -R . | jq -s .)
#      args+=(-d)
#      args+=("$json_data")
#      ;;
