#!/bin/sh

if [ "${VERBOSE}" == "yes" ]; then
	set -ex
fi

case "$1" in
	--target=csharp)
		echo "Generating C# bindings..."
		protoc --csharp_out=/data/out --proto_path=/data/in /data/in/*.proto
		echo "Generation completed successfully..."
		exit 0
		;;
	--target=typescript)
		echo "Generating TypeScript bindings..."
		protoc --plugin=protoc-gen-ts=/usr/bin/protoc-gen-ts --js_out=import_style=commonjs,binary:/data/out --ts_out=/data/out --proto_path=/data/in /data/in/*.proto
		echo "Generation completed successfully..."
		exit 0
		;;
	*)
		echo "ERROR. An --target= argument was not passed. Exiting..." >&2
		exit 255
		;;
esac
