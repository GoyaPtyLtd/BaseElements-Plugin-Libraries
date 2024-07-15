#!/bin/bash
set -e

export SRCROOT=`pwd`
cd ../../source/${PLATFORM}

rm -rf libiconv
rm -rf libxml
rm -rf libxslt

cd ${SRCROOT}

./build_xml_1_iconv.sh
./build_xml_2_libxml2.sh
./build_xml_3_libxslt.sh
