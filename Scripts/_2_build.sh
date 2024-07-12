#!/bin/bash
set -e

./build/build_boost.sh
./build/build_duktape.sh
./build/build_jq.sh

./build/build_curl_0_all.sh
./build/build_image_0_all.sh
./build/build_xml_0_all.sh

./build/build_font_0_all.sh