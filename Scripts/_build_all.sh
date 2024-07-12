#!/bin/bash
set -e

./build_boost.sh
./build_duktape.sh
./build_jq.sh

./build_curl_0_all.sh
./build_image_0_all.sh
./build_xml_0_all.sh

./macOS_build_font_0_all.sh