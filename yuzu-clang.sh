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
    gcc-11
    g++-11
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
export VCPKG_TOOLCHAIN_FILE=/tmp/vcpkg/scripts/buildsystems/vcpkg.cmake

# Setup paths for Qt binaries
export LD_LIBRARY_PATH=/opt/qt${QT_PKG_VER}/lib:${LD_LIBRARY_PATH}
export PATH=/opt/qt${QT_PKG_VER}/bin:${PATH}

# Compile yuzu
cd /home/runner
git clone --recursive https://github.com/TGP17/yuzu
cd yuzu
mkdir build || true && cd build
cmake .. \
      -DBoost_USE_STATIC_LIBS=ON \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_FLAGS="-march=x86-64-v3 -O3 -m64 -pipe" \
      -DCMAKE_CXX_COMPILER=/usr/bin/clang++-15 \
      -DCMAKE_C_COMPILER=/usr/bin/clang-15 \
      -DCMAKE_LINKER=/etc/bin/ld.lld \
      -DCMAKE_INSTALL_PREFIX="/usr" \
      -DDISPLAY_VERSION=$1 \
      -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON \
      -DENABLE_QT_TRANSLATION=ON \
      -DUSE_DISCORD_PRESENCE=ON \
      -DYUZU_ENABLE_COMPATIBILITY_REPORTING=${ENABLE_COMPATIBILITY_REPORTING:-"OFF"} \
      -DYUZU_USE_BUNDLED_FFMPEG=ON \
      -GNinja

ninja

# Separate debug symbols from specified executables
for EXE in yuzu; do
    EXE_PATH="bin/$EXE"
    # Copy debug symbols out
    objcopy --only-keep-debug $EXE_PATH $EXE_PATH.debug
    # Add debug link and strip debug symbols
    objcopy -g --add-gnu-debuglink=$EXE_PATH.debug $EXE_PATH $EXE_PATH.out
    # Overwrite original with stripped copy
    mv $EXE_PATH.out $EXE_PATH
done
# Strip debug symbols from all executables
find bin/ -type f -not -regex '.*.debug' -exec strip -g {} ';'

DESTDIR="$PWD/AppDir" ninja install
rm -vf AppDir/usr/bin/yuzu-cmd AppDir/usr/bin/yuzu-tester

# Download tools needed to build an AppImage
wget -nc https://raw.githubusercontent.com/yuzu-emu/ext-linux-bin/main/appimage/deploy-linux.sh
wget -nc https://raw.githubusercontent.com/yuzu-emu/AppImageKit-checkrt/old/AppRun.sh
wget -nc https://github.com/yuzu-emu/ext-linux-bin/raw/main/appimage/exec-x86_64.so
# Set executable bit
chmod 755 \
    deploy-linux.sh \
    AppRun.sh \
    exec-x86_64.so \

# Workaround for https://github.com/AppImage/AppImageKit/issues/828
export APPIMAGE_EXTRACT_AND_RUN=1

mkdir -p AppDir/usr/optional
mkdir -p AppDir/usr/optional/libstdc++
mkdir -p AppDir/usr/optional/libgcc_s

# Deploy yuzu's needed dependencies
DEPLOY_QT=1 ./deploy-linux.sh AppDir/usr/bin/yuzu AppDir

# Workaround for libQt5MultimediaGstTools indirectly requiring libwayland-client and breaking Vulkan usage on end-user systems
find AppDir -type f -regex '.*libwayland-client\.so.*' -delete -print

# Workaround for building yuzu with GCC 10 but also trying to distribute it to Ubuntu 18.04 et al.
# See https://github.com/darealshinji/AppImageKit-checkrt
cp exec-x86_64.so AppDir/usr/optional/exec.so
cp AppRun.sh AppDir/AppRun
cp --dereference /usr/lib/x86_64-linux-gnu/libstdc++.so.6 AppDir/usr/optional/libstdc++/libstdc++.so.6
cp --dereference /lib/x86_64-linux-gnu/libgcc_s.so.1 AppDir/usr/optional/libgcc_s/libgcc_s.so.1

# Build an AppImage
wget -nc https://github.com/yuzu-emu/ext-linux-bin/raw/main/appimage/appimagetool-x86_64.AppImage
chmod 755 appimagetool-x86_64.AppImage

# if FUSE is not available, then fallback to extract and run
if ! ./appimagetool-x86_64.AppImage --version; then
    export APPIMAGE_EXTRACT_AND_RUN=1
fi

# Don't let AppImageLauncher ask to integrate EA
echo "X-AppImage-Integrate=false" >> AppDir/org.yuzu_emu.yuzu.desktop

# Build AppImage
./appimagetool-x86_64.AppImage AppDir
