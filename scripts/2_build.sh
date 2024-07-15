#!/bin/bash
set -e

cd build 

./build_boost.sh
./build_duktape.sh
./build_jq.sh

./build_curl.sh
./build_image.sh
./build_xml.sh

./build_font.sh

cd ..
