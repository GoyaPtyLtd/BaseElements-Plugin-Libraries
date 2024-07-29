#!/bin/bash
#
#=======================================================================
#
# This just does a cleanout of the Output directory, ready to start building into.
#
# You would only use this if you've been building for a while and then wanted to start fresh.
#
#=======================================================================

export SRCROOT=`pwd`

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'
elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

cd ../Output

find ./Headers/* -not -name 'README.md' -delete

find ./Libraries/${PLATFORM}/* -not -name 'README.md' -delete

find ./Source/* -not -name 'README.md' -not -type d -delete

cd ../source/${PLATFORM}

rm -rf boost
rm -rf curl
rm -rf duktape
rm -rf fontconfig
rm -rf freetype
rm -rf ImageMagick
rm -rf jq
rm -rf libde265
rm -rf libexpat
rm -rf libheif
rm -rf libiconv
rm -rf libopenjp2
rm -rf libpng
rm -rf libssh
rm -rf libturbojpeg
rm -rf libunistring
rm -rf libxml
rm -rf libxslt
rm -rf openssl
rm -rf poco
rm -rf podofo
rm -rf zlib

cd ${SRCROOT}
