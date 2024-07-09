#!/bin/bash
set -e

./macOS_build_curl_1_openssl.sh
./macOS_build_curl_2_libssh.sh
./macOS_build_curl_3_curl.sh
./macOS_build_curl_4_poco.sh

