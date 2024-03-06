=======================================================================
macOS
=======================================================================

This was last tested with Mac OS 14.2.1, Xcode 15.2 and the 20.1.2.204 version of the SDK.

All of the documentation below is for building new versions of the libraries only.  If you are builind the plugin only, these libraries are included in the plugin repository and so do not need to be done for the macOS  plugin build to succeed.
    
As new versions of the library code is released, you're welcome to submit changes to this and we will use this to compile new versions of the plugin.

When compiling, there is a "source" and then an OS specific folder, so all the compiling is done in BaseElements-Plugin-Libraries/source/macOS and any folders are sub folders of that.  Before starting though, set the $SRCROOT variable :

`cd BaseElements-Plugin-Libraries/Output`  
`export SRCROOT=`pwd``

Then return to the folder for compiling :

`cd ../source/macOS`

=======================================================================
Boost
=======================================================================

Boost is available from

	http://www.boost.org/
	
`wget https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.zip`  
`unzip boost_1_84_0.zip`
`cd boost_1_84_0`  

`./bootstrap.sh`  
`./b2 toolset=clang cxxflags="-arch arm64 -arch x86_64" address-model=64 link=static runtime-link=static install --prefix=_build_macos --with-program_options --with-regex --with-date_time --with-filesystem --with-thread cxxflags="-mmacosx-version-min=10.15 -stdlib=libc++" linkflags="-stdlib=libc++"`  

Copy the header and library files.

`cp -R _build_macos/include/boost "${SRCROOT}/Headers"`  
`cp _build_macos/lib/*.a "${SRCROOT}/Libraries/macOS"`  

Return to source/macOS directory

`cd ..`

=======================================================================
OpenSSL
=======================================================================

Download the latest openssl source from

	http://www.openssl.org/source/

`wget https://www.openssl.org/source/openssl-3.2.1.tar.gz  
`tar -xf openssl-3.2.1.tar.gz`
`cd openssl-3.2.1`

Build for x86 :

`CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-x86_64-cc no-engine no-shared --prefix="${$(pwd)}/_build_macos_x86_64"`  
`make install`  
`make distclean`  

Build for arm64 : 

`CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-arm64-cc no-engine no-shared --prefix="${$(pwd)}/_build_macos_arm64"`  
`make install`  
`make distclean`  

Combine Architechtures : 

`mkdir _build_macos`  
`lipo -create "_build_macos_x86_64/lib/libcrypto.a" "_build_macos_arm64/lib/libcrypto.a" -output "_build_macos/libcrypto.a"`  
`lipo -create "_build_macos_x86_64/lib/libssl.a" "_build_macos_arm64/lib/libssl.a" -output "_build_macos/libssl.a"`  

Copy the header and library files.

`cp -R _build_macos_x86_64/include/openssl "${SRCROOT}//Headers"`  
`cp _build_macos/libcrypto.a ./_build_macos/libssl.a "${SRCROOT}//Libraries/macOS"`  

Return to source/macOS directory

`cd ..`

=======================================================================
libssh2
=======================================================================

Download the source from

	http://www.libssh2.org/
	
`wget https://libssh2.org/download/libssh2-1.11.0.zip`  
`unzip libssh2-1.11.0.zip`  

`cd libssh2-1.11.0`  

`CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${SRCROOT}/Headers -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/macOS/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${$(pwd)}/_build_macos" -exec-prefix="${$(pwd)}/_build_macos" --with-libz --with-crypto=openssl`  
`make -s -j install`  

Copy the header and library files.

`cp -R _build_macos/include "${SRCROOT}/Headers/libssh2"`  
`cp _build_macos/lib/libssh2.a "${SRCROOT}/Libraries/macOS"`  

Return to source/macOS directory

`cd ..`  

=======================================================================
libcurl
=======================================================================

Note: OpenSSL & libssh2 must be built before building libcurl.

Download the source from

	http://curl.haxx.se/download.html
	
`wget https://curl.se/download/curl-8.6.0.zip`
`unzip unzip curl-8.6.0.zip`
`cd curl-8.6.0`

`./configure CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/libssh2 -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/macOS" LIBS="-ldl" --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --without-libpsl --without-brotli --without-zstd --prefix="${$(pwd)}/_build_macos"`  

 # TODO this has had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others

`make -s -j install`

Copy the header and library files.

`cp -R _build_macos/include/curl "${SRCROOT}/Headers/"`
`cp _build_macos/lib/libcurl.a "${SRCROOT}/Libraries/macOS"`

Return to source/macOS directory

`cd ..`

=======================================================================
duktape
=======================================================================

Download the source from

	http://duktape.org/
	
`wget https://duktape.org/duktape-2.7.0.tar.xz`
`tar -xf duktape-2.7.0.tar.xz`

If they don't alredy exist :

`mkdir "${SRCROOT}/Source"`
`mkdir "${SRCROOT}/Source/duktape"`

`cd duktape-2.7.0`
`cp -R src "${SRCROOT}/Source/duktape"`

Return to source directory

`cd ..`

=======================================================================
libjpeg-turbo
=======================================================================

Download the source from

	https://github.com/libjpeg-turbo/libjpeg-turbo/releases
	
`wget -O libjpeg-turbo-3.0.2.tar.gz https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/3.0.2.tar.gz`  
`tar -xf libjpeg-turbo-3.0.2.tar.gz`   
`cd libjpeg-turbo-3.0.2`  

`CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON`  
`make install DESTDIR="./_build_macos"`  

Copy the header and library files.

`cp -R ./_build_macos/opt/libjpeg-turbo/include "${SRCROOT}/Headers/libturbojpeg"`  
`cp ./_build_macos/opt/libjpeg-turbo/lib/libturbojpeg.a "${SRCROOT}/Libraries/macOS"`  

Return to source directory

`cd ..`  

=======================================================================
Poco
=======================================================================

Download the source from

	http://pocoproject.org/download/

`wget https://github.com/pocoproject/poco/archive/refs/tags/poco-1.13.2-release.tar.gz`  
`tar -xf poco-1.13.2-release.tar.gz`  
`cd poco-poco-1.13.2-release`  

`./configure --config=Darwin64-clang-libc++ --prefix="${$(pwd)}/_build_macos" --no-sharedlibs --static --poquito --no-tests --no-samples --omit="CppParser,Data,Encodings,MongoDB,PDF,PageCompiler,Redis,Util" --include-path="${SRCROOT}/Headers" --library-path="${SRCROOT}/Libraries/macOS"`  

 # TODO this used to be separate x86/arm compiles, but it seems to now just build the x86 ones, which I think is wrong...

`make -s -j install`  

Copy the Headers and libraries to the project directory

`cp -R ./_build_macos/include/Poco "${SRCROOT}/Headers"`  
`cp lib/Darwin/x86_64/libPocoCrypto.a lib/Darwin/x86_64/libPocoFoundation.a lib/Darwin/x86_64/libPocoZip.a lib/Darwin/x86_64/libPocoJSON.a  lib/Darwin/x86_64/libPocoNet.a lib/Darwin/x86_64/libPocoXML.a "${SRCROOT}/Libraries/macOS"`  

Return to source directory

`cd ..`  

=======================================================================
libiconv
=======================================================================

Download the source for libiconv from

	https://www.gnu.org/software/libiconv/#downloading
	
`wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz`  
`tar -xf libiconv-1.17.tar.gz`  
`cd libiconv-1.17`  

`CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --prefix="${$(pwd)}/_build_macos"`  
`make -s -j install`  

Copy the Headers and libraries to the project directory

`mkdir "${SRCROOT}/Headers/iconv"`  
`cp -R _build_macos/include/*.h "${SRCROOT}/Headers/iconv"`  
`cp _build_macos/lib/libiconv.a  _build_macos/lib/libcharset.a "${SRCROOT}/Libraries/macOS"`  

Return to source directory

`cd ..`  

=======================================================================
libxml2
=======================================================================

Download the source for libxml2 from

	http://xmlsoft.org/downloads.html
	
`wget https://download.gnome.org/sources/libxml2/2.11/libxml2-2.11.7.tar.xz`  
`tar -xf libxml2-2.11.7.tar.xz`
`cd libxml2-2.11.7`

 # TODO This used to reference libiconv which then caused issues in libxslt so not sure how to fix it 

` --with-iconv=../libiconv-1.17/_build_macos`
 
 So for now this was taken out.  I think it will break somewhere...
 
`CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma --prefix="${$(pwd)}/_build_macos"`  

`make -s -j install`  

Copy the Headers and libraries to the project directory

`cp -R _build_macos/include/libxml2 "${SRCROOT}/Headers"`
`cp _build_macos/lib/libxml2.a "${SRCROOT}/Libraries/macOS"`

Return to source directory

`cd ..`  

=======================================================================
libxslt
=======================================================================

Download the source from

	https://github.com/GNOME/libxslt/tags
	
`wget https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.39.tar.xz`  
`tar -xf libxslt-1.1.39.tar.xz`  
`cd libxslt-1.1.39`  

`./configure CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" --disable-shared --without-python --without-crypto --with-libxml-prefix=../libxml2-2.11.7/_build_macos --prefix="${$(pwd)}/_build_macos"`   

`make -s -j install`  

Copy the Headers and libraries to the project directory

`cp -R _build_macos/include/libxslt "${SRCROOT}/Headers"`  
`cp _build_macos/lib/libxslt.a ./_build_macos/lib/libexslt.a "${SRCROOT}/Libraries/macOS"`  

Return to source directory

`cd ..`

=======================================================================
freetype
=======================================================================

Download freetype from

	https://sourceforge.net/projects/freetype/files/freetype2/
	
`wget https://sourceforge.net/projects/freetype/files/freetype2/2.13.2/freetype-2.13.2.tar.gz`  
`tar -xf freetype-2.13.2.tar.gz`  
`cd freetype-2.13.2`  

`CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --with-png=no --with-bzip2=no --with-harfbuzz=no --with-png=no --with-zlib=no --prefix="$(pwd)/_build_macos"`  

`make -s -j install`  

Copy the header and library files.

`cp -R _build_macos/include/freetype2 "${SRCROOT}/Headers"`  
`cp _build_macos/lib/libfreetype.a "${SRCROOT}/Libraries/macOS"`  

Return to source directory

`cd ..`  

=======================================================================
fontconfig
=======================================================================

Download fontconfig from

	https://www.freedesktop.org/wiki/Software/fontconfig/
	
`wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.gz`  
`tar -xf fontconfig-2.14.2.tar.gz`  
`cd fontconfig-2.14.2`  

`CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" ./configure --disable-shared --prefix="$(pwd)/_build_macos" FREETYPE_CFLAGS="-I${SRCROOT}/Headers/freetype2" FREETYPE_LIBS="-L${SRCROOT}/Libraries/macOS -lfreetype" LDFLAGS="-L${SRCROOT}/Libraries/macOS"`  
`make -s -j install`  

Copy the header and library files.

`cp -R _build_macos/include/fontconfig "${SRCROOT}/Headers"`  
`cp _build_macos/lib/libfontconfig.a "${SRCROOT}/Libraries/macOS"`  

Return to source directory

`cd ..`

=======================================================================
podofo
=======================================================================

Download podofo from

	http://podofo.sourceforge.net/download.html
	
wget -O podofo.0.10.3.tar.gz https://github.com/podofo/podofo/archive/refs/tags/0.10.3.tar.gz
tar -xf podofo.0.10.3.tar.gz
cd podofo-0.10.3

`cmake -G "Unix Makefiles" ./ -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE -DWANT_FONTCONFIG:BOOL=TRUE -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="./_build_macos" -DFREETYPE_INCLUDE_DIR="${SRCROOT}/Headers/freetype2" -DFREETYPE_LIBRARY_RELEASE="${SRCROOT}/Libraries/macOS/libfreetype.a" -DFONTCONFIG_LIBRARIES="${SRCROOT}/Libraries" -DFONTCONFIG_INCLUDE_DIR="${SRCROOT}/Headers" -DFONTCONFIG_LIBRARY_RELEASE="${SRCROOT}/Libraries/macOS/libfontconfig.a" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 -DCXX_STANDARD_REQUIRED=ON`

`make -s -j install`

Copy the header and library files.

cp -R _build_macos/include/podofo "${SRCROOT}/Headers"
cp _build_macos/lib/libpodofo.a "${SRCROOT}/Libraries/macOS"

Return to source directory

`cd ..`

=======================================================================