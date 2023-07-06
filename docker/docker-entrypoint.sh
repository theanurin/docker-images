#!/bin/sh
#

set -e

if [ -z "${PORTAINER_LIGHT_BG_COLOR}" ]; then
	echo "A variable PORTAINER_LIGHT_BG_COLOR is not set" >&2
	exit 1
fi
if [ -z "${PORTAINER_DARK_BG_COLOR}" ]; then
	echo "A variable PORTAINER_DARK_BG_COLOR is not set" >&2
	exit 2
fi
if [ -z "${PORTAINER_HIGH_BG_COLOR}" ]; then
	echo "A variable PORTAINER_HIGH_BG_COLOR is not set" >&2
	exit 3
fi

MAIN_CSS_COUNT=$(ls -1 /public/main*.css | wc -l)
if [ "${MAIN_CSS_COUNT}" == 1 ]; then 
	MAIN_CSS_FILE=$(ls -1 /public/main*.css)

	echo
	echo "Changing default background color to '${PORTAINER_LIGHT_BG_COLOR}', '${PORTAINER_DARK_BG_COLOR}', '${PORTAINER_HIGH_BG_COLOR}' in css file '${MAIN_CSS_FILE}' ..."
	echo

	sed -i "s/--bg-body-color:var(--grey-9);/--bg-body-color:${PORTAINER_LIGHT_BG_COLOR};/g"     "${MAIN_CSS_FILE}"
	sed -i "s/--bg-body-color:var(--grey-2);/--bg-body-color:${PORTAINER_DARK_BG_COLOR};/g"      "${MAIN_CSS_FILE}"
	sed -i "s/--bg-body-color:var(--black-color);/--bg-body-color:${PORTAINER_HIGH_BG_COLOR};/g" "${MAIN_CSS_FILE}"

	exec /portainer
else
	echo "This command cannot be executed because there are multiple specified files. Contact developers."
	exit 4
fi
