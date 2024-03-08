#!/bin/bash -l
#

set -e

echo
cat /BANNER
echo 
echo "KERNEL_VERSION: ${KERNEL_VERSION}"
echo "DOCKER_ARCH   : ${DOCKER_ARCH}"
echo
echo
cd /usr/src/linux
exec /bin/bash
