#!/bin/bash -E

./macOS_build_image_1_libturbojpeg.sh

#Not working yet, only produces x86 builds
./macOS_build_image_2_libde265.sh

./macOS_build_image_3_libjpeg.sh
./macOS_build_image_4_libheif.sh
./macOS_build_image_5_libopenjp2.sh
./macOS_build_image_6_imagemagik.sh
