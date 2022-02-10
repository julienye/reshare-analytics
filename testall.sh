#!/bin/bash
#
# Set the following environment variables before running this script:
#
#     PGDATABASE - "reshare_dev"
#     PGUSER - database user name
#
# For example:
#
#     $ cd sql/derived_tables/
#     $ PGDATABASE=reshare_dev PGUSER=nrn ../../testall.sh
#
set -e
# Check that the runlist exists.
if [[ ! -f runlist.txt ]]; then
    echo "testall.sh: runlist.txt not found" 1>&2
    exit 1
fi
# Check for duplicates in runlist.
if [[ $(sort runlist.txt | uniq -d) ]]; then
    echo "testall.sh: runlist.txt contains duplicates: `sort runlist.txt | uniq -d`" 1>&2
    exit 1
fi
# Run all queries.
tmpfile=`mktemp --tmpdir=. testall-XXXXXXXXXX.tmp`
trap 'rm -f -- "$tmpfile"' EXIT
for f in $( cat runlist.txt ); do
    if ! PGOPTIONS='--client-min-messages=warning' /usr/bin/time -o $tmpfile -f '%es' psql -h glintcore.net -c '\set ON_ERROR_STOP on' -f $f -Xq ; then
        exit 1
    fi
    printf 'ok\t%-50s\t%s\n' $f `cat $tmpfile` 1>&2
done || exit 1
