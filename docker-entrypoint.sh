#!/bin/sh

if [ "$(id -u)" = '0' ]; then
	echo "Started as root with args: $*"

	DATA_PARAMS_OWNER=$(stat --format '%U' /data/.zcash-params)
	if [ "x${DATA_PARAMS_OWNER}" != "xdata" ]; then
		chown -R data:data /data/.zcash-params
		chmod 700 /data/.zcash-params
	fi

	DATA_CHAIN_OWNER=$(stat --format '%U' /data/.zclassic)
	if [ "x${DATA_CHAIN_OWNER}" != "xdata" ]; then
		chown -R data:data /data/.zclassic
		chmod 700 /data/.zclassic
	fi

	exec su -c "$0 $*" data
else
	fetch-params.sh
	exec /usr/bin/zclassicd $*
fi
