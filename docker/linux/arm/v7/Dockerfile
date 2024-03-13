# https://hub.docker.com/r/gentoo/stage3
ARG GENTOO_STAGE3_IMAGE_DATE_TAG=latest

FROM --platform=linux/arm/v7 gentoo/stage3:${GENTOO_STAGE3_IMAGE_DATE_TAG} as builder
ARG GENTOO_STAGE3_IMAGE_DATE_TAG
ARG KERNEL_VERSION=
RUN test -n "${KERNEL_VERSION}" || { echo "KERNEL_VERSION is not set" >&2; exit 1; }
RUN test -n "${GENTOO_STAGE3_IMAGE_DATE_TAG}" || { echo "GENTOO_STAGE3_IMAGE_DATE_TAG is not set" >&2; exit 1; }
COPY BANNER /build/BANNER
COPY docker/docker-entrypoint-gentoo-sources-bundle.sh /build/usr/local/bin/docker-entrypoint-gentoo-sources-bundle.sh

# Target container with Gentoo Linux + necessary tools to build kernel and initramfs
FROM --platform=linux/arm/v7 gentoo/stage3:${GENTOO_STAGE3_IMAGE_DATE_TAG}
ARG GENTOO_STAGE3_IMAGE_DATE_TAG
ARG KERNEL_VERSION=
ARG KERNEL_STABILITY=
RUN \
  set -e; \
  mkdir /support; \
  mkdir -p /var/db/repos/gentoo; \
  if [ "${GENTOO_STAGE3_IMAGE_DATE_TAG}" == "latest" ]; then \
    emerge-webrsync | tee /support/emerge-webrsync.log; \
  else \
    emerge-webrsync --revert="${GENTOO_STAGE3_IMAGE_DATE_TAG}" | tee /support/emerge-webrsync.log; \
  fi; \
  [ "${KERNEL_STABILITY}" == "testing" ] && echo 'ACCEPT_KEYWORDS="~arm"' >> /etc/portage/make.conf; \
  FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox -sandbox -usersandbox" emerge --quiet =sys-kernel/gentoo-sources-${KERNEL_VERSION} | tee /support/emerge.log; \
  eselect kernel set 1; \
  echo "DOCKER_ARCH=\"linux/arm/v7\"" >> /etc/env.d/99kernel; \
  echo "KERNEL_VERSION=\"${KERNEL_VERSION}\"" >> /etc/env.d/99kernel; \
  echo "KCONFIG_OVERWRITECONFIG=\"y\"" >> /etc/env.d/99kernel; \
  env-update; \
  rm -rf /run/*; \
  rm -rf /tmp/*; \
  rm -rf /var/cache/*; \
  rm -rf /var/db/repos/*; \
  rm -rf /var/log/*; \
  rm -rf /var/tmp/*
COPY --from=builder /build /
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint-gentoo-sources-bundle.sh" ]
