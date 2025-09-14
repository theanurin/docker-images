#!/bin/sh
#

set -e

if [ -z "${PGADMIN_BG_COLOR}" ]; then
	echo "A variable PGADMIN_BG_COLOR is not set" >&2
	exit 1
fi

cp /pgadmin4/pgadmin/static/js/generated/vendor.react.js /pgadmin4/pgadmin/static/js/generated/vendor.react.js-original
sed -i "s/backgroundColor:e.otherVars.tree.inputBg/backgroundColor:'${PGADMIN_BG_COLOR}'/g" /pgadmin4/pgadmin/static/js/generated/vendor.react.js
if ! diff -q /pgadmin4/pgadmin/static/js/generated/vendor.react.js /pgadmin4/pgadmin/static/js/generated/vendor.react.js-original >/dev/null; then
  echo "Background color to '${PGADMIN_BG_COLOR}' was set successfully by patching some file(s)."
else
  echo "[BUG Detected] Failure to set background color. Target file was not patched. Pls, contact developers of the image to fix the issue." >&2
  exit 2
fi
rm /pgadmin4/pgadmin/static/js/generated/vendor.react.js-original

cp /pgadmin4/pgadmin/static/js/generated/app.bundle.js /pgadmin4/pgadmin/static/js/generated/app.bundle.js-original
sed -i "s/backgroundColor:e.palette.background.default/backgroundColor:'${PGADMIN_BG_COLOR}'/g" /pgadmin4/pgadmin/static/js/generated/app.bundle.js
if ! diff -q /pgadmin4/pgadmin/static/js/generated/app.bundle.js /pgadmin4/pgadmin/static/js/generated/app.bundle.js-original >/dev/null; then
  echo "Background color to '${PGADMIN_BG_COLOR}' was set successfully by patching some file(s)."
else
  echo "[BUG Detected] Failure to set background color. Target file was not patched. Pls, contact developers of the image to fix the issue." >&2
  exit 3
fi
rm /pgadmin4/pgadmin/static/js/generated/app.bundle.js-original

exec sudo --preserve-env --user=pgadmin --set-home /entrypoint.sh
