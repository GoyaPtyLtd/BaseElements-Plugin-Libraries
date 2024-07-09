#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libturbojpeg.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libjpeg.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libMagick++-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libMagickCore-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libMagickWand-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libopenjp2.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libheif.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libpng16.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libde265.a "${START}/BaseElements-Plugin/Libraries/macOS"


rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libturbojpeg/" "${START}/BaseElements-Plugin/Headers/libturbojpeg"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/ImageMagick-7/" "${START}/BaseElements-Plugin/Headers/ImageMagick-7"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libopenjp2/" "${START}/BaseElements-Plugin/Headers/libopenjp2"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libheif/" "${START}/BaseElements-Plugin/Headers/libheif"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libpng/" "${START}/BaseElements-Plugin/Headers/libpng"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libde265/" "${START}/BaseElements-Plugin/Headers/libde265"
