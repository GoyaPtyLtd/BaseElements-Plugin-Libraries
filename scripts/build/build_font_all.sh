#!/bin/bash
set -e

export SRCROOT=`pwd`
cd ../../source/${PLATFORM}

rm -rf libunistring
rm -rf freetype
rm -rf fontconfig
rm -rf podofo

cd ${SRCROOT}

./build_font_1_libunistring.sh
./build_font_2_freetype.sh
./build_font_3_fontconfig.sh
./build_font_4_podofo.sh
