#!/bin/bash -E

./ubuntu_build_image_1_libturbojpeg.sh

#Not working yet, only produces x86 builds
./ubuntu_build_image_2_libde265.sh

./ubuntu_build_image_3_libjpeg.sh
./ubuntu_build_image_4_libheif.sh
./ubuntu_build_image_5_libopenjp2.sh
./ubuntu_build_image_6_imagemagik.sh
