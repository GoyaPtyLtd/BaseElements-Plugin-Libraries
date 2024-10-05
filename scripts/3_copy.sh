#!/bin/bash
set -e

cd copy

./copy_boost.sh
./copy_duktape.sh
./copy_jq.sh

./copy_curl.sh
./copy_image.sh
./copy_xml.sh

./copy_font.sh

./copy_headers.sh

cd ..
