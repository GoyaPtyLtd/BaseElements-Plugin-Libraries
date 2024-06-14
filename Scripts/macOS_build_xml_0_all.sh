#!/bin/bash
set -e

./macOS_build_xml_1_iconv.sh
./macOS_build_xml_2_libxml2.sh
./macOS_build_xml_3_libxslt.sh
