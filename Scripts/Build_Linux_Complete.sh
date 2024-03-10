#install all original required organisations
sudo apt update
sudo apt upgrade
sudo apt install git-all git-lfs
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

sudo apt install codeblocks cmake gperf
sudo apt install libc++-dev libc++abi-dev libexpat1-dev
sudo apt install lld lldb liblldb-dev
sudo apt install libomp5 libomp-dev
sudo apt install llvm llvm-dev llvm-runtime libllvm-ocaml-dev
sudo apt install clang clangd clang-format clang-tidy clang-tools clang libclang-dev libclang1 python3-clang



#creating the file 
mkdir ~/source
cd ~/source
git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin.git



#set the current directory as the pwd (the basic plugin home route)
cd ~/source
export SRCROOT=`pwd`



#install boost version 1.84.0

export SRCROOT='~/source'

wget https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz
tar -xvzf boost_1_84_0.tar.gz
cd boost_1_84_0

./bootstrap.sh
./b2 link=static cflags=-fPIC cxxflags=-fPIC runtime-link=static install --prefix=_build_linux --with-program_options --with-regex --with-date_time --with-filesystem --with-thread

cp -r _build_linux/include/boost ../BaseElements-Plugin/Headers/boost
cp -r _build_linux/lib/* ../BaseElements-Plugin/Libraries/linuxARM/

cd ..


#install zlib version 

cd ~/source
wget https://www.zlib.net/zlib-1.3.1.tar.gz
tar -xvzf zlib-1.3.1.tar.gz
cd zlib-1.3.1

CFLAGS="-fPIC" ./configure --static --prefix="$(pwd)/_build_linux"
make install

cp -R _build_linux/include ../BaseElements-Plugin/Headers/zlib
cp _build_linux/lib/libz.a ../BaseElements-Plugin/Libraries/linuxARM/

cd ..


#install openssl

cd ~/source
wget https://www.openssl.org/source/openssl-3.0.13.tar.gz
tar -xvzf openssl-3.0.13.tar.gz

cd openssl-3.0.13
./Configure linux-generic64 no-engine no-hw no-shared --prefix="$(pwd)/_build_linux"
make install

cp -R _build_linux/include/openssl ../BaseElements-Plugin/Headers/
cp _build_linux/lib/libcrypto.a ./_build_linux/lib/libssl.a ../BaseElements-Plugin/Libraries/linuxARM/

cd ..

#install libssh2



cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://libssh2.org/download/libssh2-1.11.0.tar.gz
tar -xvzf libssh2-1.11.0.tar.gz
cd libssh2-1.11.0

sudo apt-get install libssl-dev

CFLAGS="-fPIC -I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib" LDFLAGS="-L${SRCROOT}/Libraries/linuxARM/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="$(pwd)/_build_linux" --with-libwolfssl-prefix
make install

cp -R _build_linux/include "${SRCROOT}/Headers/libssh2"
cp _build_linux/lib/libssh2.a "${SRCROOT}/Libraries/linuxARM"

cd ..


#install libcurl

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://curl.se/download/curl-8.6.0.tar.gz
tar -xvzf curl-8.6.0.tar.gz
cd curl-8.6.0

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
cd curl-8.6.0
CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib -I${SRCROOT}/Headers/libssh2  -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/linuxARM" LIBS="-ldl" ./configure --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --prefix="$(pwd)/_build_linux"

make install

cp -R _build_linux/include/curl "${SRCROOT}/Headers/"
cp _build_linux/lib/libcurl.a "${SRCROOT}/Libraries/linuxARM"

cd ..


#install libiconv


cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
tar -xvzf libiconv-1.17.tar.gz
cd libiconv-1.17

CFLAGS=-fPIC ./configure --disable-shared --prefix="$(pwd)/_build_linux"
make install

cp -R _build_linux/include/*.h "${SRCROOT}/Headers/iconv"
cp _build_linux/lib/libiconv.a  _build_linux/lib/libcharset.a "${SRCROOT}/Libraries/linuxARM"

cd ..



#install libxml2

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.5.tar.xz
tar -xf libxml2-2.12.5.tar.xz
cd libxml2-2.12.5

CFLAGS=-fPIC ./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma --prefix="$(pwd)/_build_linux"
make install

cp -R _build_linux/include/libxml2 "${SRCROOT}/Headers"
cp _build_linux/lib/libxml2.a "${SRCROOT}/Libraries/linuxARM"

cd ..



#install libxslt

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.38.tar.xz
tar -xf libxslt-1.1.38.tar.xz
cd libxslt-1.1.38

CFLAGS=-fPIC ./configure --disable-shared --without-python --without-crypto --prefix="$(pwd)/_build_linux"
make install

cp -R _build_linux/include/libxslt "${SRCROOT}/Headers"
cp _build_linux/lib/libxslt.a _build_linux/lib/libexslt.a "${SRCROOT}/Libraries/linuxARM"

cd ..



#install duktape

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://duktape.org/duktape-2.7.0.tar.xz
tar -xf duktape-2.7.0.tar.xz
cd duktape-2.7.0

cp -R src/* "${SRCROOT}/Source/duktape"

cd ..


#install libjpeg-turbo

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://ixpeering.dl.sourceforge.net/project/libjpeg-turbo/2.1.5.1/libjpeg-turbo-2.1.5.1.tar.gz
tar -xvzf libjpeg-turbo-2.1.5.1.tar.gz
cd libjpeg-turbo-2.1.5.1

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="./_build_linux" -DBUILD_SHARED_LIBS=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ ./
make install

cp -R _build_linux/include "${SRCROOT}/Headers/libturbojpeg"
cp _build_linux/lib/libturbojpeg.a "${SRCROOT}/Libraries/linuxARM"

cd ..


#install Poco
sudo apt install g++
cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://github.com/pocoproject/poco/archive/refs/tags/poco-1.13.2-release.tar.gz
tar -xvzf poco-1.13.2-release.tar.gz
cd poco-poco-1.13.2-release

./configure --cflags=-fPIC --typical --static --no-tests --no-samples --include-path="$(pwd)/../BaseElements-Plugin/Headers" --prefix="$(pwd)/_build_linux" --poquito --omit=CppParser,Data,Encodings,MongoDB,PDF,PageCompiler,Redis,Util
make install

cp -R _build_linux/include/Poco "${SRCROOT}/Headers"
cp _build_linux/lib/libPocoFoundation.a _build_linux/lib/libPocoCrypto.a _build_linux/lib/libPocoNet.a _build_linux/lib/libPocoXML.a _build_linux/lib/libPocoZip.a _build_linux/lib/libPocoJSON.a "${SRCROOT}/Libraries/linuxARM"



#install freetype

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://sourceforge.net/projects/freetype/files/freetype2/2.13.1/freetype-2.13.1.tar.gz
tar -xvzf freetype-2.13.1.tar.gz
cd freetype-2.13.1
        
CFLAGS="-fPIC" ./configure --disable-shared --prefix=$(pwd)/_build_linux
make install

cp -R _build_linux/include/freetype2 "${SRCROOT}/Headers"
cp _build_linux/lib/libfreetype.a "${SRCROOT}/Libraries/linuxARM"



#install fontconfig NOT WORKING

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.1.tar.gz
tar -xvzf fontconfig-2.14.1.tar.gz
cd fontconfig-2.14.1

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
cd fontconfig-2.14.1
LIBS="-lz" CFLAGS="-fPIC" ./configure --disable-shared --prefix=$(pwd)/_build_linux FREETYPE_CFLAGS="-I${SRCROOT}/Headers/freetype2"
make install

cp -R _build_linux/include/fontconfig "${SRCROOT}/Headers"
cp _build_linux/lib/libfontconfig.a "${SRCROOT}/Libraries/linuxARM"



#install podofo REQUIRES FONT CONFIG

cd ~/source/BaseElements-Plugin
export SRCROOT=`pwd`
cd ~/source
wget https://github.com/podofo/podofo/archive/refs/tags/0.10.1.tar.gz
tar -xvzf 0.10.1.tar.gz
cd podofo-0.10.1

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="./_build_linux" -DPODOFO_BUILD_STATIC:BOOL=TRUE -DFREETYPE_LIBRARY_RELEASE="${SRCROOT}/Libraries/linuxARM/libfreetype.a" -DFontconfig_INCLUDE_DIR="${SRCROOT}/Headers/fontconfig" -DFontconfig_LIBRARIES="${SRCROOT}/Libraries/linuxARM" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_CXX_FLAGS="-fPIC" ./
make install

cp -R _build_linux/include/podofo "${SRCROOT}/Headers"
cp _build_linux/lib/libpodofo.a "${SRCROOT}/Libraries/linuxARM"
