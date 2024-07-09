#!/bin/bash
set -e

./ubuntu_build_curl_1_openssl.sh
./ubuntu_build_curl_2_libssh.sh
./ubuntu_build_curl_3_curl.sh
./ubuntu_build_curl_4_poco.sh

