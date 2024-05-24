#!/bin/bash
set -e

./macOS_build_boost.sh
./macOS_build_curl_0_all.sh
./macOS_build_duktape.sh
./macOS_build_image_0_all.sh
./macOS_build_jansson.sh
./macOS_build_jq.sh
./macOS_build_poco.sh
./macOS_build_xml_0_all.sh

# the podofo library at the end of the font group has dependencies on both xml and openssl
./macOS_build_font_0_all.sh