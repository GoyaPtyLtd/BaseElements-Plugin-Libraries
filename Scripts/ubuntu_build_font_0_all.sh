#!/bin/bash
set -e

./ubuntu_build_font_1_freetype.sh
./ubuntu_build_font_2_fontconfig.sh
./ubuntu_build_font_3_podofo.sh
