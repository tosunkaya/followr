#!/usr/bin/env bash

echo "#### Updating app"
# Exit immediately if anything fails
set -e

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

FOREMAN_RUN="foreman run -e .env,.env.$RAILS_ENV"
cd "$ROOT_PATH"
if [ "$RAILS_ENV" == "production" ]; then
  ($FOREMAN_RUN bundle check || $FOREMAN_RUN bundle install --without test development profile --deployment)
else
  ($FOREMAN_RUN bundle check || $FOREMAN_RUN bundle install)
fi

$FOREMAN_RUN bundle exec rake db:migrate

[ -f "$ROOT_PATH/package.json" ] && npm install

if [ "$RAILS_ENV" == "production" ]; then
  $FOREMAN_RUN bundle exec rake assets:precompile
fi