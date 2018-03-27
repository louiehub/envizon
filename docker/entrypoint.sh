#!/bin/sh
if [ -z "$SSL_KEY_PATH" ]
then
  if [[ -f .ssl/localhost.key && -f .ssl/localhost.crt ]]
  then
    echo "Certificates found in .ssl/."
  else
    echo "No certificates provided and none in .ssl/, generating some for you"
    openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout .ssl/localhost.key -out .ssl/localhost.crt
  fi
else
  echo "Using certificates provided by environment variables."
fi

if [ -z "$SECRET_KEY_BASE" ]
then
  echo "No rails secret provided via '\$SECRET_KEY_BASE'."
  if [[ -f config/secret ]]
  then
    echo "Found a previous secret in 'config/secret:'"
    SECRET_KEY_BASE=$(<config/secret)
    echo "$SECRET_KEY_BASE"
  else
    echo "Generating one for you and placing it in 'config/secret':"
    SECRET_KEY_BASE=$(rails secret)
    echo "$SECRET_KEY_BASE"
    echo "$SECRET_KEY_BASE" > config/.secret
  fi
fi

rm -f /usr/src/app/envizon/tmp/pids/server.pid
rails db:migrate
rails db:seed
rails assets:precompile
exec rails server
