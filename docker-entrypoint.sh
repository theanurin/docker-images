#!/bin/sh
#

set -e

cd /data

echo
echo "Updating bundle ..."
echo
bundle update

echo
echo "Starting 'jekyll serve' to serve a site and rebuilds it on changes ..."
echo
exec bundle exec jekyll serve --host 0.0.0.0 --port 4000
