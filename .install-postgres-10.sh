#!/usr/bin/env bash

set -ex

echo "Installing Postgres 10"
sudo service postgresql stop
sudo apt-get remove -q 'postgresql-*'
sudo apt-get update -q
sudo apt-get install -q postgresql-10 postgresql-client-10
sudo cp /etc/postgresql/{9.6,10}/main/pg_hba.conf

echo "Restarting Postgres 10"
sudo rm /usr/local/var/postgres/postmaster.pid
sudo /etc/init.d/postgresql restart
sleep 15
psql -c 'create database redmine_test;' -U postgres
