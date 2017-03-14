#!/usr/bin/env bash

echo -e "\n# {site}:"

data=$(psql -h {local-ip} -p {local-port} -U {default_user} -d {default_db} -c 'select t1.datname AS database, pg_size_pretty(pg_database_size(t1.datname)) as size from pg_database t1 order by pg_database_size(t1.datname) desc;')

echo "${data}"
