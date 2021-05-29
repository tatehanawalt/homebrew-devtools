#!/bin/bash

debug_mode=1
write_out=1
IFS=$'\n'
max_field_len=0
NC='\033[0m' # No Color
Red='\033[0;31m'
clr=$(printf %b $Red)
nclr=$(printf %b $NC)
ferpf_color=$(echo -e "\033[38;5;24m")
# ferpf_color=$(echo -e "\033[38;5;13m")
# ferpf_color=$(echo -e "\033[38;5;100m")
alert_color=$(echo -e "\033[38;5;255m")
pref_space='   ' # Used in doc gen
lp='   '
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


clfn() {
  echo -e "\033[38;5;$1m"
}
case_signatures() {
  signatures=$(sed -n '/case \$1 in/I,/esac/I{ s/#.*//; /^[[:space:]]*$/d; /(/d; p;}' $1)
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

  # no widths stored - requires_auth is a zero or a one and the method_bodies is
  # what we use to get values used by the other methods
  # method_bodies=()

  # Does the method body contain the --auth flag
  requires_auth=()
  # the paths added to the api url to make the http request
  method_paths=()
  max_request_path_width=0
  # fields are essentially parameters embedded in the request path
  path_fields=()
  path_fields_max_width=0
  # The method we use to make the web request (POST, PUT, DELETE, etc...)
  request_methods=()
  request_method_max_width=0


  for ((i=0; i<${#methods[@]}; i++)); do
    method="${methods[$i]}"
    # printf "METHOD:\n%s\n" $method
    def=$(sed -n "/[[:space:]]$method)/I,/;;/I{ p;}" $1)
    # printf "DEF:\n%s\n" "${def[@]}"

    # Request Path
    request_path=$(echo "$def" | sed '/#/d' | grep -o "request_url.*" | sed 's/^.*=//' | tr -d '"' | tr -d "'")
    method_paths+=("$request_path")
    # printf "%s\n" $request_path
    [ ${#request_path} -gt $max_request_path_width ] && max_request_path_width=${#request_path}

    # fields which are value substitutions from the request path
    fields=$(echo "$request_path" | tr '/' '\n' | grep -o "{.*" | sort)
    field_str=$(printf "%s " $fields | sed 's/ *$//' | tr -d '{' | tr -d '}')
    path_fields+=("${field_str[@]}")
    [ ${#field_str} -gt $path_fields_max_width ] && path_fields_max_width=${#field_str}
    # printf "%s\n" $field_str

    # Request requires auth
    auth_str=$(echo "$def" | grep -o '\-\-auth')
    method_requires_auth=1
    [ ! -z "$auth_str" ] && method_requires_auth=0
    # printf "\trequires_auth: %d\n" $method_requires_auth
    requires_auth+=($method_requires_auth)

    # Request Method
    method_str=$(echo "$def" | grep -o '\-\-method[^)]*' | sed 's/.*method//' | tr -d ' ')
    request_methods+=("$method_str")
    [ ${#method_str} -gt $request_method_max_width ] && request_method_max_width=${#method_str}
  done

  val="-"
  div_bar=$(printf '=%.0s' {1..148} | sed 's/=/-/g')
  div_wall=$(echo -e "\033[31m|\033[0m")
  darker=$(echo -e "\033[31m|\235[0m")

  div_bar=$(echo $div_bar |  sed "s/^/^/")

  echo -e "\033[38;5;235m"

  printf "%s%s\n" ${lp} $div_bar
  ferpf "%smethods:                    %d\n" "${lp}" ${#methods[@]}
  ferpf "%smethod_paths:               %d\n" "${lp}" ${#method_paths[@]}
  ferpf "%spath_fields:                %d\n" "${lp}" ${#path_fields[@]}
  ferpf "%srequires_auth:              %d\n" "${lp}" ${#requires_auth[@]}
  ferpf "%srequest_methods:            %d\n" "${lp}" ${#request_methods[@]}
  ferpf "%s%s\n" "${lp}" $div_bar
  ferpf "%smax_method_signature_width: %d\n" "$lp" $max_method_signature_width
  ferpf "%smax_request_path_width:     %d\n" "$lp" $max_request_path_width
  ferpf "%spath_fields_max_width:      %d\n" "$lp" $path_fields_max_width
  ferpf "%srequest_method_max_width:   %d\n" "$lp" $request_method_max_width
  ferpf "%s%s\n" "${lp}" $div_bar

  brak_color=33
  l_brak=$(echo -e "\033[38;5;${brak_color}m{${NC}")
  r_brak=$(echo -e "\033[38;5;${brak_color}m}${NC}")

  l_brak=$(printf "{%b" "\033[38;5;${brak_color}m")
  printf -v r_brak "%b}" $NC

  for ((i=0; i<${#methods[@]}; i++)); do
    method="${methods[$i]}"
    req_path=${method_paths[$i]}
    path_fields=${path_fields[$i]}

    # Method Signature
    ferpf "${lp}$div_wall${lp}%-${max_method_signature_width}s${lp}" $method
    request_method=${request_methods[$i]}
    row_str=$(printf "${lp}$div_wall${lp}%-${max_request_path_width}s${lp}" $req_path)
    row_str=$(echo $row_str | sed "s/}/$r_brak/g" | sed "s/{/$l_brak/g")

    # Method Path
    ferpf $row_str
    #  ferpf "${lp}$div_wall${lp}%-${max_request_path_width}s${lp}" $req_path

    # Fields
    ferpf "${lp}$div_wall${lp}%-${path_fields_max_width}s${lp}" $path_fields

    # Request Http method
    ferpf "${lp}$div_wall${lp}%-${request_method_max_width}s${lp}$div_wall" $request_method
    ferpf "\n"
    # [ $(($i % 6)) -eq 5 ] && ferpf "\n"
    [ $(($i % 6)) -eq 5 ] && ferpf "%s%s\n" ${lp} ${div_bar}
  done
  ferpf "${lp}%s\n" $div_bar
  echo
}
search_file() {
  case_signatures $1
}
show_colors() {
  echo -en "\n   +  "
  for i in {0..35}; do
  printf "%2b $i" $i
  done
  printf "\n\n %3b  " 0
  for i in {0..15}; do
  echo -en "\033[48;5;${i}m $i \033[m "
  done
  #for i in 16 52 88 124 160 196 232; do
  for i in {0..6}; do
  let "i = i*36 +16"
  printf "\n\n %3b $i " $i
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


# (( bar_width = (5 * ${#lp}) + $max_method_signature_width + $max_request_path_width + $path_fields_max_width + $request_method_max_width))
# printf "${val}%s" divbar "%0.s-" {1..$bar_width}
# echo -e "\033[38;5;208mpeach\033[0;00m"
