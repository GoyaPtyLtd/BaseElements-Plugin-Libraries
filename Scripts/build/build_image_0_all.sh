#!/bin/bash
set -e

./build_image_1_libturbojpeg.sh
./build_image_2_libde265.sh
./build_image_3_libheif.sh
./build_image_4_libpng.sh
./build_image_5_libopenjp2.sh
./build_image_6_imagemagik.sh
