#!/bin/bash
#
#
#=======================================================================
#macOS
#=======================================================================
#
#This just does a cleanout of the source directory.  So gets you setup to pull new archives down to start building.
#
#You may also need to run the macOS_CleanOutput.sh file to get rid of any outputs if you run the compile step after this one.


cd ../source/macOS

#=====BOOST======
#
#Boost is available from  http://www.boost.org/
#

rm boost.tar.gz
rm -rf boost
mkdir boost

wget -q -nv -O boost.tar.gz https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz
tar -xf boost.tar.gz -C boost --strip-components=1

#=====CURL======
#
# Note: OpenSSL & libssh2 must be built before building libcurl.
#
#Download the source from  http://curl.haxx.se/download.html
#

rm curl.tar.gz
rm -rf curl
mkdir curl

wget -q -nv -O curl.tar.gz https://curl.se/download/curl-8.6.0.tar.gz
tar -xf curl.tar.gz -C curl --strip-components=1

#=====DUKTAPE======
#
#Download the source from  http://duktape.org/
#

rm duktape.tar.xz
rm -rf duktape
mkdir duktape

wget -q -nv -O duktape.tar.xz https://duktape.org/duktape-2.7.0.tar.xz
tar -xf duktape.tar.xz -C duktape --strip-components=1


#=====FONTCONFIG======
#
#Download fontconfig from   https://www.freedesktop.org/wiki/Software/fontconfig/
#

rm fontconfig.tar.gz
rm -rf fontconfig
mkdir fontconfig

wget -q -nv -O fontconfig.tar.gz https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.gz
tar -xf fontconfig.tar.gz -C fontconfig --strip-components=1

#=====FREETYPE======
#
#Download freetype from  https://sourceforge.net/projects/freetype/files/freetype2/
#

rm freetype.tar.gz
rm -rf freetype
mkdir freetype

wget -q -nv -O freetype.tar.gz https://sourceforge.net/projects/freetype/files/freetype2/2.13.2/freetype-2.13.2.tar.gz
tar -xf freetype.tar.gz -C freetype --strip-components=1

#=====JANSSON======
#
#Download the source as a ZIP archive from  https://github.com/akheron/jansson/releases
#

rm jansson.tar.gz
rm -rf jansson
mkdir jansson

wget -q -nv -O jansson.tar.gz https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.gz
tar -xf jansson.tar.gz -C jansson --strip-components=1


#=====LIBICONV======
#
#Download the source for libiconv from  https://www.gnu.org/software/libiconv/#downloading
#

rm libiconv.tar.gz
rm -rf libiconv
mkdir libiconv

wget -q -nv -O libiconv.tar.gz https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
tar -xf libiconv.tar.gz -C libiconv --strip-components=1

#=====LIBDE265======
#
#Download the source from  https://github.com/strukturag/libde265/releases
#

rm libde265.tar.gz
rm -rf libde265
mkdir libde265

wget -q -nv -O libde265.tar.gz https://github.com/strukturag/libde265/releases/download/v1.0.15/libde265-1.0.15.tar.gz
tar -xf libde265.tar.gz  -C libde265 --strip-components=1

#=====LIBJPEG======
#
#Download the source from  https://github.com/strukturag/libheif/releases
#

rm libjpeg.tar.gz
rm -rf libjpeg
mkdir libjpeg

wget -q -nv -O libjpeg.tar.gz http://ijg.org/files/jpegsrc.v9f.tar.gz
tar -xf libjpeg.tar.gz  -C libjpeg --strip-components=1

#=====LIBJP2======
#
#Download the source from  https://github.com/uclouvain/openjpeg/releases
#

rm libopenjp2.tar.gz
rm -rf libopenjp2
mkdir libopenjp2

wget -q -nv -O libopenjp2.tar.gz https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.2.tar.gz
tar -xf libopenjp2.tar.gz  -C libopenjp2 --strip-components=1

#=====LIBJPEG======
#
#Download the source from  https://github.com/strukturag/libheif/releases
#

rm libjpeg.tar.gz
rm -rf libjpeg
mkdir libjpeg

wget -q -nv -O libjpeg.tar.gz http://ijg.org/files/jpegsrc.v9f.tar.gz
tar -xf libjpeg.tar.gz  -C libjpeg --strip-components=1

#=====LIBJPEGTURBO======
#
#Download the source from  https://github.com/libjpeg-turbo/libjpeg-turbo/releases
#

rm libturbojpeg.tar.gz
rm -rf libturbojpeg
mkdir libturbojpeg

wget -q -nv -O libturbojpeg.tar.gz https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/3.0.2.tar.gz
tar -xf libturbojpeg.tar.gz  -C libjpeg --strip-components=1


#=====IMAGEMAGICK======
#
#Download the source from  https://github.com/ImageMagick/ImageMagick/releases
#

rm ImageMagick.tar.gz
rm -rf ImageMagick
mkdir ImageMagick

wget -q -nv -O ImageMagick.tar.gz https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-29.tar.gz
tar -xf ImageMagick.tar.gz  -C ImageMagick --strip-components=1


#=====JQ======
#
#Download the source from  https://github.com/jqlang/jq/releases
#

rm jq.tar.gz
rm -rf jq
mkdir jq

wget -q -nv -O jq.tar.gz https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-1.7.1.tar.gz
tar -xf jq.tar.gz  -C jq --strip-components=1


#=====LIBSSH======
#
#Download the source from  http://www.libssh2.org/
#

rm libssh.tar.gz
rm -rf libssh
mkdir libssh

wget -q -nv -O libssh.tar.gz https://libssh2.org/download/libssh2-1.11.0.tar.gz
tar -xf libssh.tar.gz -C libssh --strip-components=1

#=====LIBXML======
#
#Download the source for libxml2 from  http://xmlsoft.org/downloads.html
#

rm libxml.tar.xz
rm -rf libxml
mkdir libxml

wget -q -nv -O libxml.tar.xz https://download.gnome.org/sources/libxml2/2.11/libxml2-2.11.7.tar.xz
tar -xf libxml.tar.xz -C libxml --strip-components=1

#=====LIBXSLT======
#
#Download the source from  https://github.com/GNOME/libxslt/tags
#

rm libxslt.tar.xz
rm -rf libxslt
mkdir libxslt

wget -q -nv -O libxslt.tar.xz https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.39.tar.xz
tar -xf libxslt.tar.xz -C libxslt --strip-components=1

#=====OPENSSL======
#
#Download the latest openssl source from   http://www.openssl.org/source/
#

rm openssl.tar.gz
rm -rf openssl
mkdir openssl

wget -q -nv -O openssl.tar.gz https://www.openssl.org/source/openssl-3.2.1.tar.gz
tar -xf openssl.tar.gz -C openssl --strip-components=1

#=====POCO======
#
#Download the source from  http://pocoproject.org/download/
#

rm poco.tar.gz
rm -rf poco
mkdir poco

wget -q -nv -O poco.tar.gz https://github.com/pocoproject/poco/archive/refs/tags/poco-1.13.2-release.tar.gz
tar -xf poco.tar.gz -C poco --strip-components=1

#=====
#
#Download podofo from  http://podofo.sourceforge.net/download.html
#

rm podofo.tar.gz
rm -rf podofo
mkdir podofo

wget -q -nv -O podofo.tar.gz https://github.com/podofo/podofo/archive/refs/tags/0.10.3.tar.gz
tar -xf podofo.tar.gz -C podofo --strip-components=1


