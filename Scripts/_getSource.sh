#!/bin/bash
#
#=======================================================================
#
#This just does a cleanout of the source directory.  So gets you setup to pull new archives down to start building.
#
#=======================================================================

cd ../source

#=====BOOST======
#
#Boost is available from  http://www.boost.org/

echo "Downloading Boost ( 1 of 20 ) ..."

rm -f boost.tar.gz
wget -q -nv -O boost.tar.gz https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz

#=====CURL======
##
#Download the source from  http://curl.haxx.se/download.html

echo "Downloading Curl ( 2 of 20 ) ..."

rm -f curl.tar.gz
wget -q -nv -O curl.tar.gz https://curl.se/download/curl-8.6.0.tar.gz

#=====DUKTAPE======
#
#Download the source from  http://duktape.org/

echo "Downloading duktape ( 3 of 20 ) ..."

rm -f duktape.tar.xz
wget -q -nv -O duktape.tar.xz https://duktape.org/duktape-2.7.0.tar.xz

#=====FONTCONFIG======
#
#Download fontconfig from   https://www.freedesktop.org/wiki/Software/fontconfig/

echo "Downloading fontconfig ( 4 of 20 ) ..."

rm -f fontconfig.tar.gz
wget -q -nv -O fontconfig.tar.gz https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.gz

#=====FREETYPE======
#
#Download freetype from  https://sourceforge.net/projects/freetype/files/freetype2/

echo "Downloading freetype ( 5 of 20 ) ..."

rm -f freetype.tar.gz
wget -q -nv -O freetype.tar.gz https://sourceforge.net/projects/freetype/files/freetype2/2.13.2/freetype-2.13.2.tar.gz

#=====LIBICONV======
#
#Download the source for libiconv from  https://www.gnu.org/software/libiconv/#downloading

echo "Downloading libiconv ( 6 of 20 ) ..."

rm -f libiconv.tar.gz
wget -q -nv -O libiconv.tar.gz https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz

#=====LIBDE265======
#
#Download the source from  https://github.com/strukturag/libde265/releases

echo "Downloading libde265 ( 7 of 20 ) ..."

rm -f libde265.tar.gz
wget -q -nv -O libde265.tar.gz https://github.com/strukturag/libde265/archive/refs/tags/v1.0.15.tar.gz
#wget -q -nv -O libde265.tar.gz https://github.com/strukturag/libde265/releases/download/v1.0.15/libde265-1.0.15.tar.gz

#=====LIBJP2======
#
#Download the source from  https://github.com/uclouvain/openjpeg/releases

echo "Downloading openjpeg ( 8 of 20 ) ..."

rm -f libopenjp2.tar.gz
wget -q -nv -O libopenjp2.tar.gz https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.2.tar.gz

#=====LIBHEIF======
#
#Download the source from  https://github.com/strukturag/libheif/releases

echo "Downloading libheif ( 9 of 20 ) ..."

rm -f libheif.tar.gz
wget -q -nv -O libheif.tar.gz https://github.com/strukturag/libheif/releases/download/v1.17.6/libheif-1.17.6.tar.gz

#=====LIBJPEG======
#
#Download the source from  http://ijg.org/files/

echo "Downloading libjpeg ( 10 of 20 ) ..."

rm -f libjpeg.tar.gz
wget -q -nv -O libjpeg.tar.gz http://ijg.org/files/jpegsrc.v9f.tar.gz

#=====LIBJPEGTURBO======
#
#Download the source from  https://github.com/libjpeg-turbo/libjpeg-turbo/releases

echo "Downloading libjpeg-turbo ( 11 of 20 ) ..."

rm -f libturbojpeg.tar.gz
wget -q -nv -O libturbojpeg.tar.gz https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.3/libjpeg-turbo-3.0.3.tar.gz

#=====IMAGEMAGICK======
#
#Download the source from  https://github.com/ImageMagick/ImageMagick/releases

echo "Downloading ImageMagick ( 12 of 20 ) ..."

rm -f ImageMagick.tar.gz
wget -q -nv -O ImageMagick.tar.gz https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-29.tar.gz

#=====JQ======
#
#Download the source from  https://github.com/jqlang/jq/releases

echo "Downloading jq ( 13 of 20 ) ..."

rm -f jq.tar.gz
wget -q -nv -O jq.tar.gz https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-1.7.1.tar.gz

#=====LIBSSH======
#
#Download the source from  http://www.libssh2.org/

echo "Downloading libssh2 ( 14 of 20 ) ..."

rm -f libssh.tar.gz
wget -q -nv -O libssh.tar.gz https://libssh2.org/download/libssh2-1.11.0.tar.gz

#=====LIBXML======
#
#Download the source for libxml2 from  http://xmlsoft.org/downloads.html

echo "Downloading libxml2 ( 15 of 20 ) ..."

rm -f libxml.tar.xz
wget -q -nv -O libxml.tar.xz https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.0.tar.xz

#=====LIBXSLT======
#
#Download the source from  https://github.com/GNOME/libxslt/tags

echo "Downloading libxslt ( 16 of 20 ) ..."

rm -f libxslt.tar.xz
wget -q -nv -O libxslt.tar.xz https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.42.tar.xz

#=====OPENSSL======
#
#Download the latest openssl source from   http://www.openssl.org/source/

echo "Downloading openssl ( 17 of 20 ) ..."

rm -f openssl.tar.gz
wget -q -nv -O openssl.tar.gz https://www.openssl.org/source/openssl-3.2.1.tar.gz

#=====POCO======
#
#Download the source from  http://pocoproject.org/download/

echo "Downloading Poco ( 18 of 20 ) ..."

rm -f poco.tar.gz
wget -q -nv -O poco.tar.gz https://github.com/pocoproject/poco/archive/refs/tags/poco-1.13.3-release.tar.gz

#=====PODOFO======
#
#Download podofo from  http://podofo.sourceforge.net/download.html

echo "Downloading podofo ( 19 of 20 ) ..."

rm -f podofo.tar.gz
wget -q -nv -O podofo.tar.gz https://github.com/podofo/podofo/archive/refs/tags/0.10.3.tar.gz

#=====ZLIB======
#
#Download zlib from  https://www.zlib.net

echo "Downloading zlib ( 20 of 20 ) ..."

rm -f zlib.tar.xz
wget -q -nv -O zlib.tar.xz https://www.zlib.net/zlib-1.3.1.tar.xz

#=====Libpng======
#
#Download the source from  https://github.com/pnggroup/libpng/tags

echo "Downloading libjpeg-turbo ( 11 of 21 ) ..."

rm -f libpng.tar.gz
wget -q -nv -O libpng.tar.gz https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.43.tar.gz


echo "Downloading Complete."
