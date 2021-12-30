#!/bin/sh
#

print_usage()
{
	cat <<EOF >&2
ERROR: Bad arguments

Usage:

  IMAGES_PATH=/path/to/img
  alias luksoid='docker run --privileged=true --rm --interactive --tty --mount "type=bind,source=$IMAGES_PATH,target=/data" theanurin/luksoid'

  luksoid <Command> [Command args]

Commands:

    addpass - Add passphrase into LUKS image
        Not implemented yet

    init    - Initialize a new image file (LUKS format)
        init [--sizemb=] [--fstype=] <img file name>
            --sizemb - default value is '128'
            --fstype - default value is 'ext4'. Supported: ext2, ext3, ext4, vfat

    ls      - Show list of images (content of /data directory)

    mount   - Mount an image file
        mount [--readonly] [--fstype=] <img file name>
            --readonly - make mountpoint readonly

    rempass - Remove passphrase into LUKS image
        Not implemented yet

EOF
}

runtime_init()
{
	SIZE="128"
	FSTYPE="ext4"
	while [ -n "$1" ]; do
		case "${1}" in
			--sizemb=*)
				SIZE=$(echo "${1}" | cut -d= -f2)
				;;
			--fstype=*)
				FSTYPE=$(echo "${1}" | cut -d= -f2)
				;;
			--*=*)
				echo "ERROR: Unsupported argument '${1}'." >&2
				exit 1
				;;
			*)
				break
				;;
		esac
		shift
	done

	IMGFILE="${1}"
	if [ -z "${IMGFILE}" ]; then
		echo "ERROR: Image file name was not passed." >&2
		exit 1
	fi

	if ! echo "${SIZE}" | grep -Eq  '^[1-9][0-9]*$'; then
		echo "ERROR: Bad size value '${SIZE}'." >&2
		exit 1
	fi

	FULLIMGFILE="/data/${IMGFILE}"


	if [ -f "${FULLIMGFILE}" ]; then
		echo "ERROR: A file '${FULLIMGFILE}' already exist. If your intention is to re-create the file, try to remove it first." >&2
		exit 1
	fi


	echo -n "Initializing a zero-based file '${FULLIMGFILE}' for ${SIZE} MBytes..."
	dd if=/dev/zero of="${FULLIMGFILE}" bs=1M count="${SIZE}" >/dev/null 2>&1
	DD_EXITCODE=$?
	if [ ${DD_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'dd' application is finished with exit code '${DD_EXITCODE}'." >&2
		exit 1
	fi
	unset DD_EXITCODE
	echo " Done."
	echo

	echo -n "Checking for free loop device..."
	LOOP_DEV=$(losetup -f 2>/dev/null)
	LODETECT_EXITCODE=$?
	if [ ${LODETECT_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'losetup' application is finished with exit code '${LODETECT_EXITCODE}'." >&2
		exit 1
	fi
	unset LODETECT_EXITCODE
	echo " Done."
	echo

	echo -n "Attaching the file '${FULLIMGFILE}' to ${LOOP_DEV}..."
	losetup "${LOOP_DEV}" "${FULLIMGFILE}" 2>/dev/null
	LOSETUP_EXITCODE=$?
	if [ ${LOSETUP_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'losetup' application is finished with exit code '${LOSETUP_EXITCODE}'." >&2
		exit 1
	fi
	unset LOSETUP_EXITCODE
	echo " Done."
	echo

	relase_loopback_device()
	{
		echo -n "Releasing ${LOOP_DEV}..."
		losetup -d "${LOOP_DEV}"
		echo " Done."
	}
	trap relase_loopback_device EXIT

	echo "LUKS Formatting. Now, you will be ask for a passphrase. ALL DATA IN THE FILE '${FULLIMGFILE}' WILL BE DISCARDED!!!"
	cryptsetup --batch-mode luksFormat "${LOOP_DEV}"
	LUKSFORMAT_EXITCODE=$?
	if [ ${LUKSFORMAT_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'cryptsetup' application is finished with exit code '${LUKSFORMAT_EXITCODE}'." >&2
		exit 1
	fi
	unset LUKSFORMAT_EXITCODE
	echo "LUKS Formatting done."
	echo


	echo "LUKS Opening. Now, you will be ask for the passphrase again. We have to open your LUKS image to double-check the passphrase and make filesystem '${FSTYPE}' on it."
	LOOPNAME=$(echo "${LOOP_DEV}" | cut -c 6-)
	UNCRYPTEDNAME="uncrypted-${LOOPNAME}"
	cryptsetup luksOpen "${LOOP_DEV}" "${UNCRYPTEDNAME}"
	LUKSOPEN_EXITCODE=$?
	if [ ${LUKSOPEN_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'cryptsetup' application is finished with exit code '${LUKSOPEN_EXITCODE}'." >&2
		exit 1
	fi
	unset LUKSOPEN_EXITCODE
	echo "LUKS Opening done."
	echo

	UNCRYPTEDDEVICE="/dev/mapper/${UNCRYPTEDNAME}"

	relase_luks_device()
	{
		echo -n "LUKS Closing..."
		cryptsetup luksClose "${UNCRYPTEDDEVICE}"
		echo " Done."
		relase_loopback_device
	}
	trap relase_luks_device EXIT

	echo -n "Writing zeros to the LUKS-encrypted partition. This ensures that outside world will see this as random data i.e. it protect against disclosure of usage patterns..."
	dd if=/dev/zero of="${UNCRYPTEDDEVICE}" 1>/dev/null 2>/dev/null
	echo " Done."
	echo
	
	echo "Creating a file system '${FSTYPE}' on LUKS-encrypted partition..."
	case "${FSTYPE}" in
		ext2|ext3|ext4)
			"mkfs.${FSTYPE}" -m 0 "${UNCRYPTEDDEVICE}"
			FSCREATE_EXITCODE=$?
			;;
		vfat)
			mkfs.vfat -v "${UNCRYPTEDDEVICE}"
			FSCREATE_EXITCODE=$?
			;;
		*)
			echo "ERROR: Unsupported filesystem '${FSTYPE}'." >&2
			exit 1
			;;
	esac
	if [ ${FSCREATE_EXITCODE} -ne 0 ]; then
		echo " FAILURE. See log above to detect the problem." >&2
		exit 1
	fi
	unset FSCREATE_EXITCODE
	echo "File system was created."
	echo

	exit 0
}

runtime_ls()
{
	cd /data
	ls -1 | while read F; do printf "%-18s" $(stat -c %s "$F"); echo "$F "; done
	exit $?
}

runtime_mount()
{
	ISREADONLY="no"
	while [ -n "$1" ]; do
		case "${1}" in
			--sizemb=*)
				ISREADONLY="yes"
				;;
			--*=*)
				echo "ERROR: Unsupported argument '${1}'." >&2
				exit 1
				;;
			*)
				break
				;;
		esac
		shift
	done

	IMGFILE="${1}"
	if [ -z "${IMGFILE}" ]; then
		echo "ERROR: Image file name was not passed." >&2
		exit 1
	fi

	FULLIMGFILE="/data/${IMGFILE}"

	if [ ! -f "${FULLIMGFILE}" ]; then
		echo "ERROR: A file '${FULLIMGFILE}' not exist. Nothing to mount." >&2
		exit 1
	fi

	echo -n "Checking for free loop device..."
	LOOP_DEV=$(losetup -f 2>/dev/null)
	LODETECT_EXITCODE=$?
	if [ ${LODETECT_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'losetup' application is finished with exit code '${LODETECT_EXITCODE}'." >&2
		exit 1
	fi
	unset LODETECT_EXITCODE
	echo " Done."
	echo

	echo -n "Attaching the file '${FULLIMGFILE}' to ${LOOP_DEV}..."
	losetup "${LOOP_DEV}" "${FULLIMGFILE}" 2>/dev/null
	LOSETUP_EXITCODE=$?
	if [ ${LOSETUP_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'losetup' application is finished with exit code '${LOSETUP_EXITCODE}'." >&2
		exit 1
	fi
	unset LOSETUP_EXITCODE
	echo " Done."
	echo

	release_loopback_device()
	{
		echo -n "Releasing ${LOOP_DEV}..."
		losetup -d "${LOOP_DEV}"
		echo " Done."
	}
	trap release_loopback_device EXIT


	echo "LUKS Opening. Now, you will be ask for a passphrase."
	# Remove /dev/ to get name like 'loop0'
	LOOPNAME=$(echo "${LOOP_DEV}" | cut -c 6-)
	UNCRYPTEDNAME="uncrypted-${LOOPNAME}"
	cryptsetup luksOpen "${LOOP_DEV}" "${UNCRYPTEDNAME}"
	LUKSOPEN_EXITCODE=$?
	if [ ${LUKSOPEN_EXITCODE} -ne 0 ]; then
		echo " FAILURE. The 'cryptsetup' application is finished with exit code '${LUKSOPEN_EXITCODE}'." >&2
		exit 1
	fi
	unset LUKSOPEN_EXITCODE
	echo "LUKS Opening done."
	echo

	UNCRYPTEDDEVICE="/dev/mapper/${UNCRYPTEDNAME}"

	release_luks_device()
	{
		echo -n "LUKS Closing..."
		cryptsetup luksClose "${UNCRYPTEDDEVICE}"
		echo " Done."
		release_loopback_device
	}
	trap release_luks_device EXIT
	

	MOUNTOPTS=""
	if [ "${ISREADONLY}" == "yes" ]; then
		MOUNTOPTS="${MOUNTOPTS} -o ro"
	fi
	echo "Mounting a file system '${FSTYPE}' on LUKS-encrypted partition..."
	mount ${MOUNTOPTS} "${UNCRYPTEDDEVICE}" /mnt
	MOUNT_EXITCODE=$?
	if [ ${MOUNT_EXITCODE} -ne 0 ]; then
		echo " FAILURE. See log above to detect the problem." >&2
		exit 1
	fi
	unset MOUNT_EXITCODE
	echo "File system was mounted into '/mnt'."
	echo

	release_mount()
	{
		echo -n "Umointing '/mnt'..."
		umount /mnt
		echo " Done."
		release_luks_device
	}
	trap release_mount EXIT
	
	cd /mnt

	echo "Welcome!"
	echo
	echo "Find your LUKS-encrypted partition in /mnt directory."
	echo	
	echo "Feel free to read/write files in /mnt"
	echo
	echo "[!] Do not forget exit gracefully by 'exit' command to prevent corruption of your image file '${IMGFILE}'."
	echo


	/bin/bash
	BASH_EXITCODE=$?

	echo

	cd /

	exit ${BASH_EXITCODE}
}



if [ $# -eq 0 ]; then
	echo "ERROR: Wrong arguments. Try '--help'." >&2
	exit 1
fi

COMMAND="${1}"
shift

case "${COMMAND}" in
	init|ls|mount)
		runtime_${COMMAND} $@
		;;
	-h|--help)
		print_usage
		exit 0
		;;
	*)
		echo "ERROR: Unknown command '${COMMAND}'" >&2
		exit 1
		;;
esac

# Should never happened
echo "FATAL: Bug detected" >&2
exit 255
