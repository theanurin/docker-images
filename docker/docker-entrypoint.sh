#!/bin/sh
#

set -e

if [ $# -eq 0 ]; then
	exec /bin/bash
else
	exec /opt/flutter/bin/flutter "$@"
fi
