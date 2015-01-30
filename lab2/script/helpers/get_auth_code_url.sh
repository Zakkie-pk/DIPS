#!/bin/sh

source ./defines

URL="http://127.0.0.1:3000/resources/authorize?redirect_to=http://ya.ru&app_id=$CLIENT_ID&response_type=code"
echo $URL
