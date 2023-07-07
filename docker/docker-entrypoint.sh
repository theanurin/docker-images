#!/bin/sh
#

set -e

if [ $# -eq 0 ]; then
	FLUENTD_ARGS=""

	case "${LOG_LEVEL}" in
		trace|TRACE)
			FLUENTD_ARGS="-vv"
			;;
		debug|DEBUG)
			FLUENTD_ARGS="-v"
			;;
		info|INFO)
			FLUENTD_ARGS=""
			;;
		warn|WARN)
			FLUENTD_ARGS="-q"
			;;
		error|ERROR)
			FLUENTD_ARGS="-qq"
			;;
	esac

	exec tini -- /bin/entrypoint.sh fluentd ${FLUENTD_ARGS}
else
	exec tini -- /bin/entrypoint.sh "$@"
fi

