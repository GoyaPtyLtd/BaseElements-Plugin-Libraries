#!/bin/bash
set -e

./build_curl_1_zlib.sh
./build_curl_2_openssl.sh
./build_curl_3_libssh.sh
./build_curl_4_curl.sh
./build_curl_5_poco.sh

