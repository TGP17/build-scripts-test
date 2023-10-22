sudo apt-get update
sudo apt-get upgrade -y
sudo add-apt-repository -y ppa:savoury1/build-tools
sudo add-apt-repository -y ppa:savoury1/display
sudo add-apt-repository -y ppa:savoury1/ffmpeg4
sudo add-apt-repository -y ppa:savoury1/gcc-defaults-11
sudo add-apt-repository -y ppa:savoury1/qt-6-2
sudo add-apt-repository -y ppa:theofficialgman/gpu-tools
sudo apt-get install -y \
    build-essential \
    libsdl2-dev \
    libssl-dev \
    gcc-11 \
    g++-11 \
    cpp-11 \
    qt6-base-dev \
    qt6-base-private-dev \
    qt6-multimedia-dev \
    qt6-l10n-tools \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qt6-gtk-platformtheme \
    qt6-documentation-tools \
    qt6-wayland \
    ffmpeg \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libswresample-dev \
    libswscale-dev \
    cmake \
    p7zip-full \
    wget \
    unzip \
    git \
    ccache \
    ninja-build \
    glslang-dev \
    glslang-tools \
    file
    
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 15 all

git clone --recursive https://github.com/citra-emu/citra-nightly
cd citra-nightly
mkdir build
cd build
cmake .. -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER=clang++-15 \
    -DCMAKE_C_COMPILER=clang-15 \
    -DCMAKE_LINKER=/etc/bin/ld.lld \
    -DCITRA_ENABLE_COMPATIBILITY_REPORTING=ON \
    -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON \
    -DUSE_DISCORD_PRESENCE=ON
ninja
ninja bundle
