#!/bin/sh

if [ "$(id -u)" = '0' ]; then
	if [ ! -d /data ]; then
		mkdir /data
	fi
	chown -R postgres /data
	chmod 700 /data

	if [ ! -s "/data/PG_VERSION" ]; then
		echo "Creating database backend directory from /usr/share/postgresql.template ..."
		cp -a /usr/share/postgresql.template/* /data
	fi

	exec su -c "$0" postgres -- "$@"
else
	exec postgres -D /data
fi

