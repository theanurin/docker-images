#!/bin/sh
#

THE_PID=$$
if [ $THE_PID -eq 1 ]; then
	# Docker does not allow kill process 1, so restart as child process
	/usr/local/bin/docker-entrypoint-subversion.sh "$@"
	exit $?
fi

# Runtime
if [ $# -eq 0 ]; then
	echo
	echo "Starting Subversion container..."

	echo
	/usr/bin/svnserve --version

	echo
	echo "Correcting ownership svn:svnusers of repositories..."
	chown -R svn:svnusers .

	echo
	echo "Run SVN Serve on svn://0.0.0.0:3690"
	exec sudo --user=svn --group=svnusers /usr/bin/svnserve --daemon --root /data --listen-host 0.0.0.0 --listen-port 3690 --compression 0 --foreground --threads --max-threads 4
else
	echo "ERROR: The image is designed to be run as root user to correct owner of files." >&2
	echo "NOTE: Subversion starts as svn:svnusers." >&2
	exit 1
fi
