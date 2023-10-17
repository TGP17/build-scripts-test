export BOOST_VER=1_79_0
export CMAKE_VER=3.22.6
export GCC_VER=12.2.0
export GNU_BIN_VER=2.40
export QT_PKG_VER=515
export QT_VER=5.15.2
export UBUNTU_VER=focal

sudo apt-get update && \
   sudo apt-get full-upgrade -y && \
   sudo apt-get install --no-install-recommends -y \
    apt-utils \
    ca-certificates \
    gnupg \
    software-properties-common \
    unzip \
    wget \
    xz-utils \
    build-essential \
    ccache \
    git \
    libgl-dev \
    liblz4-dev \
    libpulse-dev \
    libudev-dev \
    libssl-dev \
    libtool \
    libwayland-dev \
    ninja-build \
    pkg-config \
    zlib1g-dev \
    appstream \
    desktop-file-utils \
    file \
    libfile-mimeinfo-perl \
    patchelf \
    zsync \
    libdrm-dev \
    libva-dev \
    libx11-dev \
    libxext-dev \
    nasm \
    autoconf \
    automake \
    libtool \
    libudev-dev \
    gpg-agent \
    curl \
    zip
    
# Install updated versions of glslang, git, and Qt from launchpad repositories
   sudo add-apt-repository -y ppa:beineri/opt-qt-${QT_VER}-${UBUNTU_VER}
   sudo add-apt-repository -y ppa:savoury1/graphics
   sudo add-apt-repository -y ppa:savoury1/multimedia
   sudo add-apt-repository -y ppa:savoury1/ffmpeg4
   sudo add-apt-repository -y ppa:git-core/ppa
   sudo apt-get update -y
   sudo apt-get install --no-install-recommends -y \
    git \
    glslang-dev \
    glslang-tools \
    libhidapi-dev \
    qt${QT_PKG_VER}base \
    qt${QT_PKG_VER}tools \
    qt${QT_PKG_VER}wayland \
    qt${QT_PKG_VER}multimedia \
    qt${QT_PKG_VER}x11extras
    
# Install Clang from apt.llvm.org
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 15 all

# Install CMake from upstream
cd /tmp && \
    wget --no-verbose https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-linux-x86_64.tar.gz && \
    tar xvf cmake-${CMAKE_VER}-linux-x86_64.tar.gz && \
    cp -rv cmake-${CMAKE_VER}-linux-x86_64/* /usr && \
    rm -rf cmake-*

# Install Boost from yuzu-emu/ext-linux-bin
cd /tmp && \
    wget --no-verbose https://github.com/yuzu-emu/ext-linux-bin/raw/main/boost/boost-${BOOST_VER}.tar.xz && \
    tar xvf boost-${BOOST_VER}.tar.xz && \
    chown -R root:root boost-${BOOST_VER}/ && \
    cp -rv boost-${BOOST_VER}/usr / && \
    rm -rf boost*

# Install GCC from yuzu-emu/ext-linux-bin
cd /tmp && \
    wget --no-verbose \
        https://github.com/yuzu-emu/ext-linux-bin/raw/main/gcc/gcc-${GCC_VER}-ubuntu.tar.xz.aa \
        https://github.com/yuzu-emu/ext-linux-bin/raw/main/gcc/gcc-${GCC_VER}-ubuntu.tar.xz.ab \
        https://github.com/yuzu-emu/ext-linux-bin/raw/main/gcc/gcc-${GCC_VER}-ubuntu.tar.xz.ac \
        https://github.com/yuzu-emu/ext-linux-bin/raw/main/gcc/gcc-${GCC_VER}-ubuntu.tar.xz.ad && \
    cat gcc-${GCC_VER}-ubuntu.tar.xz.* | tar xJ && \
    cp -rv gcc-${GCC_VER}/usr / && \
    rm -rf /tmp/gcc* && \
# Use updated libstdc++ and libgcc_s on the container from GCC 11
    rm -v /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /lib/x86_64-linux-gnu/libgcc_s.so.1 && \
    ln -sv /usr/local/lib64/libstdc++.so.6.0.30 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
    ln -sv /usr/local/lib64/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1 && \
# Help Clang find the updated GCC C++ version
    ln -sv /usr/local/include/c++/${GCC_VER}/ /usr/include/c++/${GCC_VER} && \
    ln -sv /usr/local/lib/gcc/x86_64-pc-linux-gnu/${GCC_VER} /usr/lib/gcc/x86_64-linux-gnu/${GCC_VER} && \
    cp -rv /usr/local/include/c++/${GCC_VER}/x86_64-pc-linux-gnu/* /usr/local/include/c++/${GCC_VER}/

# Install GNU binutils from yuzu-emu/ext-linux-bin
cd /tmp && \
    wget --no-verbose \
        https://github.com/yuzu-emu/ext-linux-bin/raw/main/binutils/binutils-${GNU_BIN_VER}-${UBUNTU_VER}.tar.xz && \
    tar xf binutils-${GNU_BIN_VER}-${UBUNTU_VER}.tar.xz && \
    cp -rv binutils-${GNU_BIN_VER}-${UBUNTU_VER}/usr / && \
    rm -rf /tmp/binutils*

# Setup paths for Qt binaries
export LD_LIBRARY_PATH=/opt/qt${QT_PKG_VER}/lib:${LD_LIBRARY_PATH}
export PATH=/opt/qt${QT_PKG_VER}/bin:${PATH}

# Fix GCC 11 <-> Qt 5.15 issue
cp qtconcurrentthreadengine.patch /opt/qt515/qtconcurrentthreadengine.patch
sudo patch /opt/qt515/include/QtConcurrent/qtconcurrentthreadengine.h /opt/qt515/qtconcurrentthreadengine.patch && \
    rm /opt/qt515/qtconcurrentthreadengine.patch

# Tell CMake to use vcpkg when looking for packages
export VCPKG_TOOLCHAIN_FILE=/home/yuzu/vcpkg/scripts/buildsystems/vcpkg.cmake

# Install vcpkg and required dependencies for yuzu
cd /home/yuzu &&\
    git clone --depth 1 https://github.com/Microsoft/vcpkg.git &&\
    cd vcpkg &&\
    ./bootstrap-vcpkg.sh &&\
    ./vcpkg install \
        catch2 \
        fmt \
        lz4 \
        nlohmann-json \
        zlib \
        zstd
