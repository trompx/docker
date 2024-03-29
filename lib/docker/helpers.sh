#!/bin/sh
set -e

helpers_yaml=$(cd "$(dirname $0)/.."; pwd)/script/yaml
default_user=envygeeks; user=
while getopts ":u:" opt "$@"; do
  case $opt in
    u) user=$OPTARG; user_set_user=true;;
  esac
done
shift $((
  OPTIND-1
))

if [ -z "$user" ]; then
  user=$default_user
fi

# By default we expect you to send `script/build -u user repo:tag`, however,
# because we would like to stay the same as `docker` above the `script/build` in
# a particular `dockerfiles/*` we also accept `script/build user/repo:tag`. This
# is not meant to be used in any scenario but the root `script/build`
#
# The current_user is set above and beyond the user, so if you send a user and
# we detect it, and then you send `user/repo:tag` then the current user will be
# that particular user unless you didn't send `-u` then we will use the base
# default: `$default_user`

parse_repository() {
  if echo "$1" | grep -q '/'; then
    current_user=$(echo $1 | awk -F/ '{ print $1 }')
    repo=$(echo "$1" | awk -F/ '{ print $2 }' | awk -F: '{ print $1 }')
     tag=$(echo "$1" | awk -F/ '{ print $2 }' | awk -F: '{ print $2 }')
  else
    if [ "$user_set_user" ] || [ ! -f opts.yml ] || [ -z "$($helpers_yaml user)" ]; then
      current_user=$user
    else
      current_user=$(
        $helpers_yaml user
      )
    fi

    repo=$(echo "$1" | awk -F: '{ print $1 }')
     tag=$(echo "$1" | awk -F: '{ print $2 }')
  fi

}

# Providing a user ($1) with a repo ($2) we will return all of the built tags so
# that you can do as you please with it.
# @return 0

available_images_with_tags() {
  for v in $(docker images | grep -E "^$1/$2" | awk '{ print $2 }' | sort -u); do
    printf "%s/%s:%s\n" "$1" "$2" "$v"
  done
}

# Clears the screen unless DISABLE_CLEAR is passed.
# This also supports travis folding, just send the tag and title.
# @returns 0

clear_screen() {
  if [ -z "$DISABLE_CLEAR" ]; then
    tput clear || true
    if [ $# -gt 0 ]; then
      printf "travis_fold:%s\r\033[0K" "$@"
    fi
  fi
}

printf_black()   { tput setaf 0; printf "$@"; tput sgr0; }
printf_red()     { tput setaf 1; printf "$@"; tput sgr0; }
printf_green()   { tput setaf 2; printf "$@"; tput sgr0; }
printf_yellow()  { tput setaf 3; printf "$@"; tput sgr0; }
printf_blue()    { tput setaf 4; printf "$@"; tput sgr0; }
printf_magenta() { tput setaf 5; printf "$@"; tput sgr0; }
printf_cyan()    { tput setaf 6; printf "$@"; tput sgr0; }
printf_white()   { tput setaf 7; printf "$@"; tput sgr0; }
echo_black()     { tput setaf 0;   echo "$@"; tput sgr0; }
echo_red()       { tput setaf 1;   echo "$@"; tput sgr0; }
echo_green()     { tput setaf 2;   echo "$@"; tput sgr0; }
echo_yellow()    { tput setaf 3;   echo "$@"; tput sgr0; }
echo_blue()      { tput setaf 4;   echo "$@"; tput sgr0; }
echo_magenta()   { tput setaf 5;   echo "$@"; tput sgr0; }
echo_cyan()      { tput setaf 6;   echo "$@"; tput sgr0; }
echo_white()     { tput setaf 7;   echo "$@"; tput sgr0; }
run_black()      { tput setaf 0;   eval "$@"; tput sgr0; }
run_red()        { tput setaf 1;   eval "$@"; tput sgr0; }
run_green()      { tput setaf 2;   eval "$@"; tput sgr0; }
run_yellow()     { tput setaf 3;   eval "$@"; tput sgr0; }
run_blue()       { tput setaf 4;   eval "$@"; tput sgr0; }
run_magenta()    { tput setaf 5;   eval "$@"; tput sgr0; }
run_cyan()       { tput setaf 6;   eval "$@"; tput sgr0; }
run_white()      { tput setaf 7;   eval "$@"; tput sgr0; }
