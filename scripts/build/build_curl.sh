#!/bin/bash
set -e

export SRCROOT=`pwd`
cd ../../source/${PLATFORM}

rm -rf zlib
rm -rf openssl
rm -rf libssh
rm -rf curl
rm -rf poco

cd ${SRCROOT}

./build_curl_1_zlib.sh
./build_curl_2_openssl.sh
./build_curl_3_libssh.sh
./build_curl_4_nghttp2.sh
./build_curl_5_curl.sh
./build_curl_6_poco.sh

