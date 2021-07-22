#!/bin/bash

helpers_start_time=$(date +%s)
silent_mode=1
debug_mode=1
max_field_len=0

# Specify Colors
noc=$(echo -en '\033[0m')
red=$(echo -en '\033[0;31m')
blue_navy=$(echo -en '\033[38;5;25m')
blue=$(echo -en '\033[38;5;33m')
dark_grey=$(echo -en '\033[38;5;235m')

# Assign colors
error_color=$red
log_color=$blue_navy
ferpf_color=$dark_grey
decorate_color=$noc
field_color=$blue

lp=' '
table_indent=''
print_debug_header=1
HELPERS_LOG_TOPICS=()

function debug() {
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
function in_ci() {
  [ -z "$CI" ] && return 1
  [ "$CI" = "true" ] && return 0
  return 1
}
function pre_args() {
  # Parse args for silent, debug etc...
  for arg in $@; do
    case $arg in
      -d) debug_mode=0;; # Print debug logging
      -s) # silent mode - disables output (including debug messages)
        silent_mode=0
        eval "exec 2> /dev/null"
        ;;
    esac
  done
}
function case_signatures() {
  div_bar=$(printf '=%.0s' {1..123} | sed 's/=/-/g' | sed "s/^/$decorate_color/")
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
  method_names=()             # method names
  method_name_max_width=0     # max width of any method name
  method_paths=()             # the paths added to the api url to make the http request
  max_request_path_width=0    # max width of any path used
  path_fields=()              # fields are essentially parameters embedded in the request path
  path_fields_max_width=0     # max width of field set
  request_methods=()          # The method we use to make the web request (POST, PUT, DELETE, etc...)
  request_method_max_width=0  # max width of any request method
  requires_auth=()            # Does the method body contain the --auth flag

  for ((i=0; i<${#methods[@]}; i++)); do
    method="${methods[$i]}"
    def=$(sed -n "/[[:space:]]$method)/I,/;;/I{ p;}" $1)

    # Request Path
    request_path=$(echo "$def" | sed '/#/d' | grep -o "request_url.*" | sed 's/^.*=//' | tr -d '"' | tr -d "'")

    [ -z "$request_path" ] && continue
    method_names+=("$method")
    [ ${#method} -gt $method_name_max_width ] && method_name_max_width=${#method}

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

  # First horizontal bar of the table
  ferpf "%s%s\n" "$table_indent" "$div_bar"

  # Print the actual table
  for ((i=0; i<${#method_names[@]}; i++)); do
    printf -v sig_row "%s%-${method_name_max_width}s%s" "$lp" "${method_names[$i]}" "$lp"
    printf -v path_row "%s%-${max_request_path_width}s%s" "$lp" "${method_paths[$i]}" "$lp"
    # Row substitutions (highlighting)
    path_row=$(echo $path_row | sed "s/}/$ferpf_color}/g" | sed "s/{/{$field_color/g")
    printf -v fields_row "%s%-${path_fields_max_width}s%s" "$lp" "${path_fields[$i]}" "$lp"
    printf -v request_method_row "%s%-${request_method_max_width}s%s" "$lp" "${request_methods[$i]}" "$lp"
    ferpf "%s" "$table_indent"       # Table row offset indent (set above, not here)
    ferpf "%s" "$div_wall"           # Table Row Entrypoint
    ferpf "%s" "${sig_row}"          # Method Signature
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "%s" "${path_row}"         # Request Path
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "%s" "$fields_row"         # Fields
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "%s" "$request_method_row" # Request Method
    ferpf "%s" "$div_wall"           # Vertical Divider
    ferpf "\n"                       # End of row
  done
  ferpf "%s%s" "$table_indent" "$div_bar" # Last horizontal bar in the table
}
function search_file() {
  case_signatures $1
}
function ferpf() { # Write to standard error
  if [ ${#@} -lt 1 ]; then
    echo 1>&2
    return
  fi
  printf "%b" $ferpf_color
  printf $* 1>&2
  # printf "%b" $noc
}
function set_fg() {
  if [ $1 -eq -1 ]; then
    echo -en '\033[0m'
  else
    echo -en "\033[38;5;${1}m"
  fi
}
function set_bg() {
  if [ $1 -eq -1 ]; then
    echo -en '\033[0m'
  else
    echo -en "\033[48;5;${1}m"
  fi
}
function pallette() {
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
  set_fg -1
  set_bg -1
  echo
}
function show_colors() {
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
function before_exit() {
  [ -z "$HELPERS_LOG_TOPICS" ] && return
  write_result_set "$(join_by , ${HELPERS_LOG_TOPICS[@]})" outputs
  log
  return 0
}

# Shared github api helper method
function git_req() {
  pre_args $@

  can_exec=0

  IFS=$'\n'
  positional=()
  args=()
  local req_url=""
  while [ $# -gt 0 ]; do
    key="$1"
    shift
    case $key in
      --auth)
        if [ -z "$GITHUB_AUTH_TOKEN" ]; then
          write_error "GITHUB_AUTH_TOKEN not set in git_Req - line $LINENO"
          can_exec=1
        else
          args+=(-H "Authorization: token $GITHUB_AUTH_TOKEN")
        fi
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
        [[ "$1" =~ ^/ ]] && write_error "git_req url invalid format. url must not start witha /. url=${1} - line $LINENO" exit 1
        [ ! -z "$req_url" ] && write_error "Attempted to set req_url twice. this can only be done once. - line $LINENO" && exit 1
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

  args+=(-s)

  # Output Format - see https://curl.se/docs/manpage.html
  args+=(-w)
  args+=("HTTPSTATUS:%{http_code}")

  # Headers:
  args+=(-H)
  args+=("Accept: application/vnd.github.v3+json")
  args+=("https://api.github.com/$req_url")

  [ $can_exec -ne 0 ] && write_error "can_exec -ne 0... - line $LINENO" && exit 1

  response=$(curl ${args[@]})
  local status_code=$(echo "$response" | tail -n 1 | sed 's/.*HTTPSTATUS://g')
  echo "$response"| sed 's/HTTPSTATUS.*//g'
}

# CSV set helpers
function for_csv() {
  IFS=$'\n'
  for field in $(echo $1 | tr ',' '\n'); do
    [ -z "$field" ] && continue
    $2 $field
  done
}
function csv_max_length() {
  IFS=$'\n'
  max_field_len=0
  for field in $(printf $1 | tr ',' '\n'); do
    [ ${#field} -gt $max_field_len ] && max_field_len=$((${#field}))
  done
  echo "$max_field_len"
}
function join_by() {
  local d=${1-} f=${2-};
  if shift 2; then
    printf %s "$f" "${@/#/$d}" | sed "s/ $d/$d/g"
    #| sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
    #printf %s "$f" "${@/#/$d}" | sed "s/[^[:alnum:]]$d/$d/g" | sed 's/[^[:alnum:]]$//g'
  fi
}
function contains() {
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
function get_prefix() {
  printf "\t"
}
function write_error() {
  echo -en $error_color
  echo "::error::$1"
  echo -en $noc
}
function log() {
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
function log_result_set() {
  printf "$(get_prefix)%s\n" $(echo -e $1 | tr ',' '\n')
}
function command_log_which() {
  printf "%s\t%s\n" $1 "$(which $1)"
  printf "%s\n" "$2" | sed "s/^.*divider-bin-\([0-9.]*\).*/\1/"
}
function write_result_set() {
  IFS=$'\n'
  result=$(echo -e "$1" | sed 's/"//g')
  [ -z "$result" ] && return 1
  shift
  key=$1
  [ -z "$key" ] && key="result"
  key=$(echo $key | tr [[:lower:]] [[:upper:]])
  result="${result//'%'/'%25'}"
  result="${result//$'\n'/'%0A'}"
  result="${result//$'\r'/'%0D'}"
  echo "::set-output name=$key::$(echo -e $result)"
  HELPERS_LOG_TOPICS+=($key)
}
function print_field() {
  printf "%s=$(eval "echo \"\$$1\"")\n" $1
}
function print_field_table() {
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
function default_labels() {
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


# Git repo helpers
function git_repo_root() {
  local root_dir="$(git rev-parse --show-toplevel)"
  [ ! -d "$root_dir" ] && write_error "git_repo_root root_dir not a directory - line $LINENO" && return 1
  printf "%s" $root_dir
}
function git_repo_name() {
  local root_dir="$(git rev-parse --show-toplevel)"
  [ ! -d "$root_dir" ] && write_error "git_repo_root root_dir not a directory - line $LINENO" && return 1
  basename $root_dir
}

# Formula Functions:
# ==============================================================================
function formulas_dir() {
  [ ! -z "$FORMULAS_DIR" ] && [ -d "$FORMULAS_DIR" ] && printf "%s" "$FORMULAS_DIR" && return 0
  if [ ! -z "$GITHUB_WORKSPACE" ] && [ -d "$GITHUB_WORKSPACE/Formula" ];
  then
    FORMULAS_DIR="$GITHUB_WORKSPACE/Formula"
    printf "%s" "$FORMULAS_DIR"
    return 0
  fi
  local_git_root=$(git_repo_root)
  [ $? -ne 0 ] && write_error "formulas_dir local_git_root error - line $LINENO" && return 1
  [ ! -d "$local_git_root/Formula" ] && write_error "formulas_dir local_git_root error - line $LINENO" && return 1
  FORMULAS_DIR="$local_git_root/Formula"
  printf "%s" "$FORMULAS_DIR"
}

function formula_names() {
  f_dir=$(formulas_dir)
  [ $? -ne 0 ] && write_error "formula_names error - line $LINENO" && return 1
  find "$f_dir" \
    -maxdepth 1 \
    -type f \
    -name '*.rb' \
    -exec basename {} \; | \
    sed 's/\..*//' | \
    sort -u
}

function formula_path() {
  f_dir=$(formulas_dir)
  [ $? -ne 0 ] && write_error "formulas_dir error - line $LINENO" && return 1
  [ ! -d "$f_dir" ] && write_error "FORMULA_DIR not a directory - line $LINENO" && return 1
  [ ! -f "$f_dir/$1.rb" ] && write_error "$f_dir/$1.rb not a file - line $LINENO" && return 1
  printf "$f_dir/$1.rb"
}
function formula_paths() {
  for item in $(formula_names); do
    val=$(formula_path $item)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}

function formula_file() {
  formula_path=$(formula_path $1)
  [ $? -ne 0 ] && printf "$1 formula path not found\n" && return 1
  cat $formula_path
}

function formula_header() {
  formula_file $1 | sed -n '/#/,/^$/{/^$/q;p;}'
}
function formula_description() {
  formula_header $1 | grep "^# desc.*$" | sed 's/^.*://g'
}
function formula_method_signatures() {
  IFS=$'\n'
  slim_file=$(formula_file $1 | \
    sed 's/#.*//' | \
    grep -o '.*[[:alnum:]].*' | \
    sed 's/.*".*//' | \
    sed "s/.*'.*//" | \
    sed '/^$/d')
  signatures_prefix=$(printf "${slim_file}\n" | head -n 2 | tail -n 1 | sed 's/[[:alnum:]].*//')
  file_body=$(printf "$slim_file" | grep "^$signatures_prefix[^ ].*")
  prev=""
  for row in $file_body; do
    [[ "$row" =~ ^[[:space:]]+end ]] && printf "%s\n" "$prev"
    prev=$row
  done
}
function formula_method_body() {
  IFS=$'\n'
  slim_file=$(formula_file $1 | sed '/#.*/d')
  sub_slim_file=$(echo "$slim_file" | \
    sed 's/.*".*//' | \
    sed "s/.*'.*//" | \
    sed '/^$/d')
  echo "$sub_slim_file"
  # Standard padding for a method signature
  signatures_prefix=$(echo "$sub_slim_file" | head -n 2 | tail -n 1 | sed 's/[[:alnum:]].*//')
  # printf "|%s|\n\n" $signatures_prefix
  echo "$slim_file" | awk "/$2/,/^${signatures_prefix}end/"
}
function formula_sha() {
  formula_method_body $1 $2 | \
    grep "sha256.*" | \
    tr \' \" | \
    cut -d '"' -f 2
}
function formula_url() {
  IFS=$'\n'
  formula_method_body "$1" "$2" | \
    grep 'url.*' | \
    tr \' \" | \
    cut -d '"' -f 2
}

function formula_stable_shas() {
  for item in $(formula_names); do
    val=$(formula_sha $item stable)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_stable_urls() {
  for item in $(formula_names); do
    val=$(formula_url "$item" "stable")
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}

function formula_head_shas() {
  for item in $(formula_names); do
    val=$(formula_sha $item head)
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}
function formula_head_urls() {
  for item in $(formula_names); do
    val=$(formula_url "$item" "head")
    [ -z "$val" ] && continue
    printf "${item} ${val}\n"
  done
}

function formula_signatures() {
  IFS=$'\n'
  for item in $(formula_names); do
    printf "%s\n" $item
    formula_method_signatures $item
  done
}



# README gen functions:
# ------------------------------------------------------------------------------
# args:
# 1 - html item i.e 'div', 'span' etc...
# 2 - html fields i.e 'id', 'class' etc...
# 3 - content to wrap
function html_wrap() {
  item="$1"
  shift
  printf '<%s' "$item"
  [ ! -z "$1" ] && printf ' %s' "$1"
  printf '>\n'
  shift
  IFS=$'\n'
  while [ $# -gt 0 ]; do
    printf "%s\n" $1
    shift
  done
  printf '</%s>' "$item"
}
function just_wrap() {
  printf '%s%s%s%s%s' "$1" "$2" "$3" "$2" "$1"
}
function code() {
  printf '```%s\\n' "$1"
  shift
  while [ $# -gt 0 ]; do
    printf '%s\\n' "$1"
    shift
  done
  printf '```'
}
function link_me() {
  printf '[%s]' $1
  shift
  printf '(%s)' $1
}
# ------------------------------------------------------------------------------



function test_local() {
  GITHUB_WORKSPACE='/Users/tatehanawalt/Documents/dev/homebrew-devtools'
  GITHUB_REPOSITORY_OWNER=tatehanawalt
  GITHUB_REPOSITORY=homebrew-devtools
  ID=22
}


pre_args $@

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
  write_error "test error - line $LINENO"
  echo 1>&2
  log sample_log
  ferpf
fi
