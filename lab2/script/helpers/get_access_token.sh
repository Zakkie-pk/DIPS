#!/bin/sh

source ./defines

CODE=$1
ARGS="redirect_to=http://example.com/cb&app_id=$CLIENT_ID&grant_type=authorization_code&secret_key=$CLIENT_SECRET&code=$CODE"
URL="http://127.0.0.1:3000/access_token"

curl --data "$ARGS" "$URL"
