#!/bin/bash

psql -h 127.0.0.1 -U postgres -W -f create.sql

echo "start term1"
psql -h 127.0.0.1 -d hw4 -U postgres -W -f term1.sql &
sleep 10

echo "start term2"
psql -h 127.0.0.1 -d hw4 -U postgres -W -f term2.sql

echo "end term2"
