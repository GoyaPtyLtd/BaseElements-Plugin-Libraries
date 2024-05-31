# BaseElements-Plugin-Libraries

Each OS in the libraries has it's own setup requirements. These could be a shell script, but we've left them here as commands to run individually in case you may have already done some of them.

These only need to be run once, preferably before you even pull down any of the source code.

### macOS Setup

On the mac you compile for x86, arm and iOS all from the one place, but the compile scripts are separate for macOS and iOS ( at the moment.

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

    cd BaseElements-Plugin-Libraries/Scripts

    ./_getSource.sh
    ./_macOS_build_all.sh

### Ubuntu Setup

    sudo apt update
    sudo apt install git-all git-lfs codeblocks
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
    sudo apt install clang-format clang-tidy clang-tools clang clangd libc++-dev libc++abi-dev libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang gcc-multilib g++-multilib
    sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

    sudo mkdir /opt/FileMaker
    sudo chown "${USER:=$(/usr/bin/id -run)}:$USER" /opt/FileMaker

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git

We run codeblocks via sudo as it usually means that it can find the various libraries it needs easier. If there's a better way to do that, then that would be good :)
