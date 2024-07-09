#!/bin/bash
set -e

./ubuntu_build_image_1_libturbojpeg.sh
./ubuntu_build_image_2_libde265.sh
./ubuntu_build_image_3_libjpeg.sh
./ubuntu_build_image_4_libheif.sh
./ubuntu_build_image_5_libopenjp2.sh
./ubuntu_build_image_6_imagemagik.sh
