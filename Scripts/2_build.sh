#!/bin/bash
set -e

cd build 

./build_boost.sh
./build_duktape.sh
./build_jq.sh

./build_curl_0_all.sh
./build_image_0_all.sh
./build_xml_0_all.sh

./build_font_0_all.sh

cd ..
