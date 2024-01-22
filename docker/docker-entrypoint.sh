#!/bin/sh
#

set -e

echo
echo "Changing default background color to '${PGADMIN_BG_COLOR}' ..."
echo

sed -i "s/background-color:#fff !important/background-color:${PGADMIN_BG_COLOR} !important/g" /pgadmin4/pgadmin/static/js/generated/pgadmin.css
if [ -z "${PGADMIN_BG_COLOR}" ]; then
	echo "A variable PGADMIN_BG_COLOR is not set" >&2
	exit 1
fi

exec sudo --preserve-env --user=pgadmin --set-home /entrypoint.sh
