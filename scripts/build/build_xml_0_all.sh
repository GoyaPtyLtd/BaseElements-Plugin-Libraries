#!/bin/bash
set -e

./build_xml_1_iconv.sh
./build_xml_2_libxml2.sh
./build_xml_3_libxslt.sh
