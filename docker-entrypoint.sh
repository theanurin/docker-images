#!/bin/sh

if [ "${VERBOSE}" == "yes" ]; then
	set -ex
fi

PROCOC_EXIT_CODE=255

case "$1" in
	--target=csharp)
		echo "Generating C# bindings..."
		protoc "--csharp_out=${DATA_OUT}" "--proto_path=${DATA_IN}" "${DATA_IN}"/*.proto
		PROCOC_EXIT_CODE=$?
		;;
	--target=typescript)
		echo "Generating TypeScript bindings..."
		protoc --plugin=protoc-gen-ts=/usr/bin/protoc-gen-ts "--js_out=import_style=commonjs,binary:${DATA_OUT}" "--ts_out=${DATA_OUT}" "--proto_path=${DATA_IN}" "${DATA_IN}"/*.proto
		PROCOC_EXIT_CODE=$?
		;;
	*)
		echo "ERROR. An --target= argument was not passed. Exiting..." >&2
		exit 255
		;;
esac

if [ ${PROCOC_EXIT_CODE} -eq 0 ]; then
	echo "Generation completed successfully."
else
	echo "ERROR. Generation failure with exit code: ${PROCOC_EXIT_CODE}"
fi
exit ${PROCOC_EXIT_CODE}