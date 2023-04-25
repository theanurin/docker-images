#!/bin/sh
#

set -e

cd /data

if [ $# -eq 0 ]; then
    echo
    echo "Warning! Command line arguments is empty."
    echo
    echo "I will execute:"
    echo "  update bundle"
    echo "  jekyll serve"
    echo
    echo "Feel free to pass your own command line arguments for Jekyll."

    echo
    echo "Updating bundle ..."
    echo
    bundle update

    echo
    echo "Starting 'jekyll serve' to serve a site and rebuilds it on changes ..."
    echo
    exec jekyll serve --host 0.0.0.0 --port 4000
else
    exec jekyll "$@"
fi