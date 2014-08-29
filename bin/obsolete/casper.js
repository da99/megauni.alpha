#!/usr/bin/env bash
# -*- bash -*-
#

if [ -z "$1" ];
then FILE="all";
else FILE="$1";
fi

set -u
bin/kill_test_server
set -e

PORT=5001
echo ""
echo "Starting server on $PORT..."

if [[ "$FILE" == "all" || "$FILE" == "01" ]]; then
  TESTING=true PORT=$PORT bin/start &
  PORT=$PORT casperjs test/01-casper-disconnect.js $PORT
fi

if [[ "$FILE" != "01" ]]; then
  bin/migrate reset_with_customer
  PORT=$PORT bin/start &
fi

if [[ "$FILE" == "all" || "$FILE" == "02" ]]; then
  PORT=$PORT casperjs test/02-casper-sign-in.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "03" ]]; then
  PORT=$PORT casperjs test/03-casper-create-account.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "04" ]]; then
  PORT=$PORT casperjs test/04-casper-create-screen-name.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "05" ]]; then
  PORT=$PORT casperjs test/05-casper-delete-screen-name.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "06" ]]; then
  PORT=$PORT casperjs test/06-casper-change-homepage-privacy.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "07" ]]; then
  PORT=$PORT casperjs test/07-casper-change-homepage.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "08" ]]; then
  PORT=$PORT casperjs test/08-casper-load-homepage.js $PORT
fi

if [[ "$FILE" == "all" || "$FILE" == "09" ]]; then
  PORT=$PORT casperjs test/09-casper-add-to-homepage.js $PORT
fi


trap "bin/kill_test_server" EXIT


