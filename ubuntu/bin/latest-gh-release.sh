#!/usr/bin/env bash

# from https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] sarg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    # -f | --flag) flag=1 ;; # example flag
    # -p | --param) # example named parameter
    #   param="${2-}"
    #   shift
    #   ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  # [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# script logic here

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"

# LATEST_RELEASE=$(http -j "https://api.github.com/repos/${args[0]}/releases/latest" | jq '. | {url: .html_url, name: .name, downloads: .assets[].browser_download_url} | select(.downloads | contains ("amd64")) | select (.downloads | contains("musl") == false) | .downloads' | tr -d '"')
LATEST_RELEASE=$(http -j "https://api.github.com/repos/${args[0]}/releases/latest" | jq '. | {url: .html_url, name: .name, downloads: .assets[].browser_download_url} | select(.downloads | contains ("amd64")) | select (.downloads | contains("musl") == false)')

LR_VERSION=$(echo $LATEST_RELEASE | jq '.name' | tr -d '"')
LR_URL=$(echo $LATEST_RELEASE | jq '.downloads' | tr -d '"')

echo "latest release of ${args[0]} is $LR_VERSION; available at $LR_URL"
echo -e 'link: \e]8;;'$LR_URL'\e\\'$LR_VERSION'\e]8;;\e\\\n'