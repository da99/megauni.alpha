#!/usr/bin/env mksh
# -*- mksh -*-
#
set -u -e -o pipefail

files="$(find Public/ -type f \( -name '*.js' -or -name "*.css" -or -name "*.gif" -or -name "*.jpg" -or -name "*.styl" \))"

for f in $files
do
  echo "$f" "$(stat -c %Y "$f")"
done


