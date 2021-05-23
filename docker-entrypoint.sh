#!/bin/sh

if [ "$(id -u)" = '0' ]; then
	chown -R tonos:tonos /data
	chmod 700 /data
	exec su tonos $0 -- "$@"
else
	exec tonos-cli "$@"
fi
