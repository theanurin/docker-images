#!/bin/sh

if [ "$(id -u)" = '0' ]; then
	echo "Started as root with args: $*"

	DATA_PARAMS_OWNER=$(stat --format '%U' /data)
	if [ "x${DATA_PARAMS_OWNER}" != "xdata" ]; then
		chown -R data:data /data
		chmod 700 /data
	fi

	exec su -c "$0 $*" data
else
	exec /usr/local/bin/litecoind $*
fi
