sudo apt-get install -y \
    build-essential \
    libsdl2-dev \
    libssl-dev \
    gcc-11 \
    g++-11 \
    cpp-11 \
    clang \
    clang-format \
    libc++-dev \
# Qt 6
    qt6-base-dev \
    qt6-base-private-dev \
    qt6-multimedia-dev \
    qt6-l10n-tools \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qt6-gtk-platformtheme \
    qt6-documentation-tools \
    qt6-wayland \
# FFmpeg
    ffmpeg \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libswresample-dev \
    libswscale-dev \
# Tools
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

git clone --recursive https://github.com/citra-emu/citra
mkdir build
cd build
cmake .. -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DENABLE_QT_TRANSLATION=ON \
    -DCITRA_ENABLE_COMPATIBILITY_REPORTING=ON \
    -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON \
    -DUSE_DISCORD_PRESENCE=ON
ninja
