#!/bin/bash
set -e

SRCROOT=$(pwd)
cd ../../source/${PLATFORM}

rm -rf libunistring
rm -rf freetype
rm -rf fontconfig
rm -rf podofo

cd "${SRCROOT}"

./build_font_1_libunistring.sh
./build_font_2_libexpat.sh
./build_font_3_freetype.sh
./build_font_4_fontconfig.sh
