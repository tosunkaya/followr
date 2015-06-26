#!/usr/bin/env bash

# Exit immediately if anything fails
set -euo pipefail
IFS=$'\n\t'

echo "#### Global provisioning"

##### Check if running as root

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

##### Load environment variables

echo ""
echo "-- Loading environment variables"

if [ "$2" == "" ]; then
  echo "> Trying to infer root path from own path..."
  DEPLOY_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  ROOT_PATH=$(readlink -m "$DEPLOY_PATH/..")
else
  ROOT_PATH="$2"
  DEPLOY_PATH="$ROOT_PATH/provision"
fi

echo "> Root path is: $ROOT_PATH"
[ -f "$ROOT_PATH/.env" ] && source "$ROOT_PATH/.env"
: ${RAILS_ENV:=development}
[ -f "$ROOT_PATH/.env.$RAILS_ENV" ] && source "$ROOT_PATH/.env.$RAILS_ENV"

DOMAIN="$1"
export DEBIAN_FRONTEND=noninteractive


##### Setup repositories

echo ""
echo "-- Setting up repositories"
sed -i "/^# deb .*multiverse/ s/^# //" /etc/apt/sources.list && echo "> Enabled multiverse"
add-apt-repository -y ppa:brightbox/ruby-ng &> /dev/null && echo "> ppa:brightbox/ruby-ng added" || (echo "Error adding ppa:brightbox/ruby-ng" && exit 1)
add-apt-repository -y ppa:chris-lea/node.js &> /dev/null && echo "> ppa:chris-lea/node.js added" || (echo "Error adding ppa:chris-lea/node.js" && exit 1)

echo ""
echo "-- Removing unused packages"
apt-get -yq remove juju chef ruby* puppet x11-common x11-xkb-utils xserver-common xserver-xorg-core > /dev/null
apt-get -yq autoremove > /dev/null

echo ""
echo "-- Updating system"
apt-get -q update > /dev/null
apt-get -yq dist-upgrade > /dev/null


##### Install Ruby, Node.js, basic dependencies

echo
echo "-- Installing Ruby, Node.js and basic dependencies"
apt-get -yq install build-essential ruby2.2 ruby2.2-dev build-essential libpq-dev libv8-dev libsqlite3-dev nodejs sqlite3 git nano curl htop libxslt-dev libxml2 libxml2-dev libssl-dev > /dev/null

echo
echo "-- Installing global gems"
gem update --system > /dev/null
gem update > /dev/null
gem install --no-document bundler foreman

##### Install & configure Nginx

echo
echo "-- Installing Nginx"
apt-get -yq install nginx > /dev/null
yes | cp -rf $DEPLOY_PATH/conf/nginx/* /etc/nginx/conf.d/
sed -i "s#{{ROOT}}#$ROOT_PATH/public#" /etc/nginx/conf.d/*.conf
sed -i "s#{{DOMAIN}}#$DOMAIN#g" /etc/nginx/conf.d/*.conf

service nginx restart

##### Install Redis

echo
echo "-- Installing Redis"
apt-get -y -q install redis-server > /dev/null

service redis-server restart


##### Install PostgreSQL
PG_VERSION=9.3

echo
echo "-- Installing PostgreSQL $PG_VERSION"
apt-get -yq install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION" > /dev/null

PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

echo "host    all             all             all                     md5" >> "$PG_HBA"
sed -i 's/^local\\s\\+all\\s\\+all\\s\\+peer/local all all md5/g' "$PG_HBA"

echo "client_encoding = utf8" >> "/etc/postgresql/$PG_VERSION/main/postgresql.conf"

service postgresql restart


##### Create DB

PREFIX=APP
DB_VAR=${PREFIX}_DB
USER_VAR=${PREFIX}_DB_USER
PASSWORD_VAR=${PREFIX}_DB_PASSWORD

DB=${!DB_VAR}
USER=${!USER_VAR}
PASSWORD=${!PASSWORD_VAR}


echo ""
echo "-- Creating PostgreSQL database for '$PREFIX'"
echo "  > User: $USER"
echo "  > Password: $PASSWORD"
echo "  > Database name: $DB"

cat << EOF | su - postgres -c psql

-- Create the database user:
CREATE USER $USER WITH PASSWORD '$PASSWORD';

-- Create the database:
CREATE DATABASE $DB WITH OWNER=$USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;

\c $DB
CREATE EXTENSION "uuid-ossp";
EOF
