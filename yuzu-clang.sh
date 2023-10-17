export BOOST_VER=1_79_0
export CLANG_VER=15
export CMAKE_VER=3.22.6
export GCC_VER=12.2.0
export GNU_BIN_VER=2.40
export QT_PKG_VER=515
export QT_VER=5.15.2
export UBUNTU_VER=focal

sudo add-apt-repository -y ppa:savoury1/build-tools
sudo add-apt-repository -y ppa:savoury1/display
sudo add-apt-repository -y ppa:savoury1/ffmpeg4
sudo add-apt-repository -y ppa:savoury1/gcc-defaults-11
sudo add-apt-repository -y ppa:savoury1/graphics
sudo add-apt-repository -y ppa:theofficialgman/gpu-tools
sudo add-apt-repository -y ppa:savoury1/multimedia
sudo add-apt-repository -y ppa:git-core/ppa
sudo add-apt-repository -y ppa:beineri/opt-qt-${QT_VER}-${UBUNTU_VER}

sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get install -y \
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
    git \
    glslang-dev \
    glslang-tools \
    libhidapi-dev \
    qt${QT_PKG_VER}base \
    qt${QT_PKG_VER}tools \
    qt${QT_PKG_VER}wayland \
    qt${QT_PKG_VER}multimedia \
    qt${QT_PKG_VER}x11extras \
    zip
    
# Install Clang from apt.llvm.org
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 15 all
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 150
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 150

# Install CMake from upstream
cd /tmp && \
    wget --no-verbose https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-linux-x86_64.tar.gz && \
    tar xvf cmake-${CMAKE_VER}-linux-x86_64.tar.gz && \
    sudo cp -rv cmake-${CMAKE_VER}-linux-x86_64/* /usr && \
    rm -rf cmake-*

# Install Boost from yuzu-emu/ext-linux-bin
cd /tmp && \
    wget --no-verbose https://github.com/yuzu-emu/ext-linux-bin/raw/main/boost/boost-${BOOST_VER}.tar.xz && \
    tar xvf boost-${BOOST_VER}.tar.xz && \
    sudo cp -rv boost-${BOOST_VER}/usr / && \
    rm -rf boost*

# Install vcpkg and required dependencies for yuzu
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
        
# Tell CMake to use vcpkg when looking for packages
export VCPKG_TOOLCHAIN_FILE=./scripts/buildsystems/vcpkg.cmake

# Compile yuzu
git clone --recursive https://github.com/yuzu-emu/yuzu-mainline
cd yuzu-mainline
mkdir build || true && cd build
cmake .. \
      -DBoost_USE_STATIC_LIBS=ON \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_FLAGS="-march=x86-64-v2" \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_INSTALL_PREFIX="/usr" \
      -DDISPLAY_VERSION=$1 \
      -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON \
      -DENABLE_QT_TRANSLATION=ON \
      -DUSE_DISCORD_PRESENCE=ON \
      -DYUZU_ENABLE_COMPATIBILITY_REPORTING=${ENABLE_COMPATIBILITY_REPORTING:-"OFF"} \
      -DYUZU_USE_BUNDLED_FFMPEG=ON \
      -DYUZU_ENABLE_LTO=ON \
      -GNinja

ninja
