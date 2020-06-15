#!/bin/bash -e
if [[ "$(realpath -s "${0}")" =~ [[:blank:]] ]]; then echo "Can't run ${0} with spaces in path."; exit 1; fi

source_dir=$(dirname $(realpath -s ${0}))/build
output_dir=p-frontend1:/srv/htdocs/frontend

echo "Uploading to ${output_dir}..."
rsync \
    --verbose \
    --progress \
    --8-bit-output \
    --human-readable=1 \
    --recursive \
    --links \
    --copy-unsafe-links \
    --delete \
    --perms \
    --times \
    --compress-level=7 \
    --timeout=30 \
     ${source_dir}/ \
     ${output_dir} \
|| exit 1

exit 0
