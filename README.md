# BaseElements-Plugin-Libraries

This is set of scripts and tools that are used to build the external libraries used in the BE plugin : https://github.com/GoyaPtyLtd/BaseElements-Plugin

If you want to compile the BE plugin, then you don't need this, the current main build of the BE plugin should compile as is on latest macOS at least. Working with this library is only to build newer versions of the open source libraries used in the BE Plugin. If you're experienced in shell scripting, or in compiling open source tools, then we'd love some help with this project.

### Goals

The goal is to turn this into a single script for each FileMaker platform ( Mac, Windows, Ubuntu linux ) that builds the various open source libraries in a configuration that works in the BE Plugin. Each library can then be updated and copied along with it's dependencies into the main BE Plugin folder

### TODO

1. Check the imageMagick compile uses all the libraries we've compiled and not others.
2. Add all the iOS build stuff to the mac scripts.
3. Build a Windows script library.
4. Build ubuntu x86 and arm versions.

If you're at all interested in the BE plugin and compiling code for it, or helping out, we'd love some assistance.

### Getting Started

To start with, we recommend you fork the BaseElements-Plugin-Libraries repository to your own account so you can test and push changes into the fork instead of our main - that makes it easier to submit patches.

Each of the different OS versions has it's own Setup routine, that is a one off.

### macOS Setup

On the mac you compile for x86, arm and iOS all from the one place, so the compile scripts for mac will build both macOS and iOS versions ( eventually, we're working on macOS only for now ).

You need to install **XCode** and the XCode command line tools.

There are a bunch of open source tools required as well, to make things easier we recommend you install these with [brew](https://brew.sh). Open that link then follow the install instructions there. Our set of installed tools are :

    brew install autoconf automake cmake gettext git git-lfs gnu-tar libtool m4 pkg-config protobuf wget xz

Not all of these may be needed, this was we had last time we checked. You want to avoid using lots of brew libraries as the compile options may find those instead of the ones we've built into the scripts.

You also need to configure git with git-lfs :

    git lfs install

It shouldn't matter where you put the local version of the repository, but we put it at ~/Documents/GitHub :

    cd ~
    mkdir Documents/GitHub
    cd Documents/GitHub

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git

If you're compiling the plugin you may also need to clone it :

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin.git

Then switch to the Scripts folder as the base from which to call various compile scripts.

    cd BaseElements-Plugin-Libraries/Scripts
    chmod +x ./*

Then run the script that downloads all the current source files :

    ./_getSource.sh

You don't need to re-run this unless it changes in github and there's a new version of one of the libraries. Each build process starts from a clean folder and unpacks the archive at the beginning, so you only need to download once. You can then run any of the individual build scripts, or build everything :

    ./_macOS_build_all.sh

Once you've built a library or set of libraries and you want to test the plugin build folder, switch to the Copy folder from Scripts and run a copy script :

    cd Copy
    ./_macOS_copy_boost.sh

Then open XCode, and try a build from there. If it succeeds, run the "BaseElements Plugin Tests.fmp12" file test scripts. If there's issues, we need to resolve them, either in the BE Plugin code, or in the compile settings for that library.

### Ubuntu Setup

Just documenting this here as none of the ubuntu script are tested yet.

    sudo apt update
    sudo apt install git-all git-lfs codeblocks
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
    sudo apt install clang-format clang-tidy clang-tools clang clangd libc++-dev libc++abi-dev libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang gcc-multilib g++-multilib gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

    sudo mkdir /opt/FileMaker
    sudo chown "${USER:=$(/usr/bin/id -run)}:$USER" /opt/FileMaker

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git

We run codeblocks via sudo as it usually means that it can find the various libraries it needs easier. If there's a better way to do that, then that would be good :)

### Windows Setup

TODO
