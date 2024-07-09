#!/bin/bash
set -e

./build_curl_1_openssl.sh
./build_curl_2_libssh.sh
./build_curl_3_curl.sh
./build_curl_4_poco.sh

