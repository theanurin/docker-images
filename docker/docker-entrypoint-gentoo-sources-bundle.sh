#!/bin/bash
#

set -e

echo
cat /BANNER
echo 
echo -n "KERNEL_VERSION: "
cat /KERNEL_VERSION | head -n 1
echo -n "DOCKER_ARCH   : "
cat /DOCKER_ARCH | head -n 1
echo
echo
cd /usr/src/linux
exec /bin/bash
