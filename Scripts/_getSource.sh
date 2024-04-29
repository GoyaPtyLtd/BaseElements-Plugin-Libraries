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

rm boost.tar.gz
wget -q -nv -O boost.tar.gz https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz

#=====CURL======
##
#Download the source from  http://curl.haxx.se/download.html

rm curl.tar.gz
wget -q -nv -O curl.tar.gz https://curl.se/download/curl-8.6.0.tar.gz

#=====DUKTAPE======
#
#Download the source from  http://duktape.org/

rm duktape.tar.xz
wget -q -nv -O duktape.tar.xz https://duktape.org/duktape-2.7.0.tar.xz

#=====FONTCONFIG======
#
#Download fontconfig from   https://www.freedesktop.org/wiki/Software/fontconfig/

rm fontconfig.tar.gz
wget -q -nv -O fontconfig.tar.gz https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.gz

#=====FREETYPE======
#
#Download freetype from  https://sourceforge.net/projects/freetype/files/freetype2/

rm freetype.tar.gz
wget -q -nv -O freetype.tar.gz https://sourceforge.net/projects/freetype/files/freetype2/2.13.2/freetype-2.13.2.tar.gz

#=====JANSSON======
#
#Download the source as a ZIP archive from  https://github.com/akheron/jansson/releases

rm jansson.tar.gz
wget -q -nv -O jansson.tar.gz https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.gz

#=====LIBICONV======
#
#Download the source for libiconv from  https://www.gnu.org/software/libiconv/#downloading

rm libiconv.tar.gz
wget -q -nv -O libiconv.tar.gz https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz

#=====LIBDE265======
#
#Download the source from  https://github.com/strukturag/libde265/releases

rm libde265.tar.gz
wget -q -nv -O libde265.tar.gz https://github.com/strukturag/libde265/archive/refs/tags/v1.0.15.tar.gz
#wget -q -nv -O libde265.tar.gz https://github.com/strukturag/libde265/releases/download/v1.0.15/libde265-1.0.15.tar.gz

#=====LIBJP2======
#
#Download the source from  https://github.com/uclouvain/openjpeg/releases

rm libopenjp2.tar.gz
wget -q -nv -O libopenjp2.tar.gz https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.2.tar.gz

#=====LIBHEIF======
#
#Download the source from  https://github.com/strukturag/libheif/releases

rm libheif.tar.gz
wget -q -nv -O libheif.tar.gz https://github.com/strukturag/libheif/releases/download/v1.17.6/libheif-1.17.6.tar.gz

#=====LIBJPEG======
#
#Download the source from  http://ijg.org/files/

rm libjpeg.tar.gz
wget -q -nv -O libjpeg.tar.gz http://ijg.org/files/jpegsrc.v9f.tar.gz

#=====LIBJPEGTURBO======
#
#Download the source from  https://github.com/libjpeg-turbo/libjpeg-turbo/releases

rm libturbojpeg.tar.gz
wget -q -nv -O libturbojpeg.tar.gz https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/3.0.2.tar.gz

#=====IMAGEMAGICK======
#
#Download the source from  https://github.com/ImageMagick/ImageMagick/releases

rm ImageMagick.tar.gz
wget -q -nv -O ImageMagick.tar.gz https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-29.tar.gz

#=====JQ======
#
#Download the source from  https://github.com/jqlang/jq/releases

rm jq.tar.gz
wget -q -nv -O jq.tar.gz https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-1.7.1.tar.gz

#=====LIBSSH======
#
#Download the source from  http://www.libssh2.org/

rm libssh.tar.gz
wget -q -nv -O libssh.tar.gz https://libssh2.org/download/libssh2-1.11.0.tar.gz

#=====LIBXML======
#
#Download the source for libxml2 from  http://xmlsoft.org/downloads.html

rm libxml.tar.gz
wget -q -nv -O libxml.tar.gz https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.12.6/libxml2-v2.12.6.tar.gz

#=====LIBXSLT======
#
#Download the source from  https://github.com/GNOME/libxslt/tags

rm libxslt.tar.gz
wget -q -nv -O libxslt.tar.gz https://gitlab.gnome.org/GNOME/libxslt/-/archive/v1.1.39/libxslt-v1.1.39.tar.gz

#=====OPENSSL======
#
#Download the latest openssl source from   http://www.openssl.org/source/

rm openssl.tar.gz
wget -q -nv -O openssl.tar.gz https://www.openssl.org/source/openssl-3.2.1.tar.gz

#=====POCO======
#
#Download the source from  http://pocoproject.org/download/

rm poco.tar.gz
wget -q -nv -O poco.tar.gz https://github.com/pocoproject/poco/archive/refs/tags/poco-1.13.2-release.tar.gz

#=====PODOFO======
#
#Download podofo from  http://podofo.sourceforge.net/download.html

rm podofo.tar.gz
wget -q -nv -O podofo.tar.gz https://github.com/podofo/podofo/archive/refs/tags/0.10.3.tar.gz

#=====ZLIB======
#
#Download zlib from  https://www.zlib.net

rm zlib.tar.gz
wget -q -nv -O zlib.tar.gz https://www.zlib.net/zlib-1.3.1.tar.gz


