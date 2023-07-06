#!/bin/sh
#
set -e

sed -i -e "/background-color:/s/#ffffff;/${REDIS_COMMANDER_BG_COLOR};/" /redis-commander/web/static/css/default.css

echo
echo "Changing default background color to '${REDIS_COMMANDER_BG_COLOR}' ..."
echo

exec sudo --preserve-env --user=redis /redis-commander/docker/entrypoint.sh