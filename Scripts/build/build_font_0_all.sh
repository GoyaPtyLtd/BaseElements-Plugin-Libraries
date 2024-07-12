#!/bin/bash
set -e

./build_font_1_libunistring.sh.sh
./build_font_2_freetype.sh
./build_font_3_fontconfig.sh
./build_font_4_podofo.sh
