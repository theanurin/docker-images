#!/bin/sh

case "$1" in
	help)
		echo
		echo "-------------------------------------------------------------------------------------"
		echo "    Following a content of README.md. See more details inside sources repository.    "
		echo "-------------------------------------------------------------------------------------"
		echo
		echo
		cat /usr/local/sqlrunner/README.md
		exit 1
		;;
	banner)
		shift
		if [ -n "${DATA_DIRECTORY}" ]; then
			if [ ! -d "${DATA_DIRECTORY}" ]; then
				echo "Container does not have embedded migration scripts in '${DATA_DIRECTORY}'" >&2
				exit 1
			fi
			if [ ! -f "${DATA_DIRECTORY}/BANNER" ]; then
				echo "Embedded migration scripts does not have banner file: '${DATA_DIRECTORY}/BANNER'" >&2
				exit 2
			fi
		fi
		exec cat /var/local/sqlrunner/BANNER
		;;
	*)
		[ -n "${DATA_DIRECTORY}" -a -f "${DATA_DIRECTORY}/BANNER" ] && cat "${DATA_DIRECTORY}/BANNER"
		exec /usr/local/sqlrunner/bin/sqlrunner.js "$@"
		;;
esac
