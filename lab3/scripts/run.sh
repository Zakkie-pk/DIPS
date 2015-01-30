#!/bin/sh

. ./service.conf

echo $$ | tee .gpid
../front/script/front daemon -l "http://*:$SERVICE_FRONT_PORT" &
../main_logic/script/main_logic daemon -l "http://*:$SERVICE_LOGIC_PORT" &
../session/script/session daemon -l "http://*:$SERVICE_SESSION_PORT" &
../backend_aircrafts/script/backend_aircrafts daemon -l "http://*:$SERVICE_AIRCRAFTS_PORT" &
../backend_companies/script/backend_companies daemon -l "http://*:$SERVICE_COMPANIES_PORT" &
