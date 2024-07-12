#!/bin/bash
set -e

./macOS_build_font_1_freetype.sh
./macOS_build_font_2_fontconfig.sh
./macOS_build_font_3_podofo.sh
