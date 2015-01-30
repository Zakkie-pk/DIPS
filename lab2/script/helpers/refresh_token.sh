#!/bin/sh

source ./defines

REFRESH_TOKEN=$1

ARGS="app_id=$CLIENT_ID&grant_type=refresh_token&secret_key=$CLIENT_SECRET&refresh_token=$REFRESH_TOKEN"
URL="http://127.0.0.1:3000/refresh_token"

curl --data "$ARGS" "$URL"
