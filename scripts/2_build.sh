#!/bin/bash

# Note: We are building with clang under Linux, it is possible to
# verify this in Output/Libraries/{platform}/ by running:
#   for i in *.a; do echo "++ Checking: $i"; strings -a $i | grep GCC | grep -v except_table; done
# There should be no output in the form:
#   GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0

set -e

cd build

./build_duktape.sh
./build_jq.sh

./build_curl.sh
./build_font.sh
./build_image.sh
./build_xml.sh

./build_boost.sh

./build_podofo.sh

cd ..
