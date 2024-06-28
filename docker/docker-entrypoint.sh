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
    echo "  bundle exec jekyll serve --host '0.0.0.0' --port 4000 --livereload --livereload_port 4001 --incremental"
    echo
    echo "Feel free to pass your own command line (as image arguments). Some examples:"
    echo "  bundle exec jekyll new .                                                 - Generate a new site"
    echo "  bundle exec jekyll serve --host '0.0.0.0' --port 4000 --trace --profile  - Customize serve mode"
    echo "  bundle update                                                            - Update your dependencies (and Gemfile.lock)"
    echo
    echo "Install bundles ..."
    echo
    bundle install

    echo
    echo "Starting to serve the site and rebuilds it on changes ..."
    echo
    exec bundle exec jekyll serve --host '0.0.0.0' --port 4000 --livereload --livereload_port 4001 --incremental
else
    exec "$@"
fi