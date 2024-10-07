#!/bin/bash
set -e

SRCROOT=${PWD}
cd ../../source/${PLATFORM}

rm -rf libturbojpeg
rm -rf libde265
rm -rf libheif
rm -rf libpng
rm -rf libopenjp2
rm -rf ImageMagick

cd "${SRCROOT}"

./build_image_1_libturbojpeg.sh
./build_image_2_libde265.sh
./build_image_3_libpng.sh
./build_image_4_libheif.sh
./build_image_5_libopenjp2.sh
./build_image_6_imagemagik.sh
