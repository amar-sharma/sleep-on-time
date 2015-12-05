#!/bin/bash
# Written by Amar Sharma <amarsharma.hacker@gmail.com>

TYPE=$1
PASS_LENGTH=17
EMAIL_TO="amarsharma.hacker@gmail.com"
PASS_FILE="/tmp/d0n3"

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
  curl -s -m 5 -L --retry 3 http://google.com 2>&1 > /dev/null
  if [[ $? -eq 0 ]]; then
    echo "Online"
  else
    echo "Offline"
  fi
}

battery_stat() {
  echo `pmset -g batt | grep % | awk '{split($2,a,"%"); print a[1]}'`
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

lock_screen() {
  sudo open -a /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app || true
}

set_password() {
  password=`random_passwd`
  sudo dscl . -passwd $HOME $password
  if [[ $TYPE == "random" ]]; then
    send_email $password
    sleep 3
    if [[ `network_stat` != "Online" ]]; then
      TYPE="default"
      set_password
    fi
    rm -f $PASS_FILE
    lock_screen
  else
    touch $PASS_FILE
  fi
}

main() {
  if [[ $# == 0 ]] ; then
    usage
  fi
  if [[ $TYPE == "default" && -f $PASS_FILE ]]; then
    return
  fi
  if [[ `network_stat` == "Online" && `battery_stat` > 10 || $TYPE == "default" ]]; then
    set_password
  else
    echo "No Internet or battery !!! safely exiting"
  fi
}

main $@

