#!/bin/bash
set -e

./copy/copy_boost.sh
./copy/copy_duktape.sh
./copy/copy_jq.sh

./copy/copy_curl.sh
./copy/copy_image.sh
./copy/copy_xml.sh

./copy/copy_font.sh