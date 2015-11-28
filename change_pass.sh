#!/bin/bash
# Written by Amar Sharma <amarsharma.hacker@gmail.com>

TYPE=$1
PASS_LENGTH=32
EMAIL_TO="amarsharma.hacker@gmail.com"

MAIL_GUN=0 # If you want to use @mailgun, set to 1
# @mailgun settings
API_KEY="key-xxxxxxxxxxxxxxxx"
BASE_URL="https://api.mailgun.net/v3/xxxxxxxxxxxxxxxxxxxxxxxxx"
MAIL_FROM="mailgun@xxxxxxxxxxxxxxxxxxxxxxxxx"

trap "exit 3" TERM

usage() {
  echo "Usage: "`basename $0`" [default|random]" 1>&2
  echo "Example: "`basename $0`" default" 1>&2
  kill -s TERM $$
}

network_stat() {
  wget -q --tries=10 --timeout=20 --spider http://google.com 2>&1 > /dev/null
  if [[ $? -eq 0 ]]; then
    echo "Online"
  else
    echo "Offline"
  fi
}

random_passwd() {
  if [[ $TYPE == "default" ]]; then
    echo "default_password"
  elif [[ $TYPE == "random" ]]; then
    echo `date +%s | shasum | base64 | head -c $PASS_LENGTH`
  else
    usage
  fi
}

send_email() {
  if [[ $MAIL_GUN == 1 ]]; then
    curl --user "api:$API_KEY" \
      $BASE_URL/messages \
      -F from='Pass Cron<'$MAIL_FROM'>' \
      -F to=$EMAIL_TO\
      -F subject='Sleep Tight' \
      -F text="You don't have to do this: $1"
  else
    echo "You don't have to do this: $1" | mail -s "Sleep Tight" $EMAIL_TO
  fi
}

set_password() {
  password=`random_passwd`
  sudo dscl . -passwd $HOME $password
  if [[ $TYPE == "random" ]]; then
    send_email $password
  fi
}

main() {
  if [[ `network_stat` == "Online" ]]; then
    echo `random_passwd`
    set_password
  else
    echo "No Internet!!! safely exiting"
  fi
}

if [[ $# == 0 ]] ; then
  usage
fi

main $@
