#!/bin/sh
#

set -e

cd /data

if [ $# -eq 0 ]; then
    echo
    echo "Warning! Command line arguments is empty."
    echo
    echo "I will execute:"
    echo "  bundle install"
    echo "  jekyll serve"
    echo
    echo "Feel free to pass your own command line (as image arguments). Some examples:"
    echo "  jekyll new .  - Generate a new site"
    echo "  bundle update - Update your Gemfile.lock"

    echo
    echo "Install bundles ..."
    echo
    bundle install

    echo
    echo "Starting 'jekyll serve' to serve a site and rebuilds it on changes ..."
    echo
    exec jekyll serve --host 0.0.0.0 --port 4000
else
    exec "$@"
fi