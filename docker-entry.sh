#!/bin/sh

set -e

RETRY="20"
PORT="3000"

: "${RAILS_ENV:="development"}"

: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"

: "${DB_HOST:="postgres"}"
: "${DB_PORT:="5432"}"
: "${DB_USERNAME:="postgres"}"
: "${DB_PASSWORD:="postgres"}"

wait_for_port() {
	local name="$1" host="$2" port="$3"
	local j=0
	while ! nc -vz "$host" "$port" >/dev/null 2>&1 < /dev/null; do
		j=$((j+1))
		if [ $j -ge $RETRY ]; then
			echo >&2 "$(date) - $host:$port not reachable, giving up"
			exit 1
		fi
		echo "$(date) - waiting for $name... $j/$RETRY"
		sleep 5
	done
}

app() {
  rails db:create && rails db:migrate
  rails assets:precompile
  rails s -e production
}

if [ "${RAILS_ENV}" != "production" ]; then
	wait_for_port "Postgres" "$DB_HOST" "$DB_PORT"
	wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
fi

case "$1" in
	app)
		app
		;;
	sidekiq)
		exec bundle exec sidekiq -e production
		;;
	*)
		exec bundle exec "$@"
		;;
  esac
