#!/usr/bin/env bash

# Installs ffmpeg from source (HEAD) with libaom and libx265, as well as a few
# other common libraries
# binary will be at ~/bin/ffmpeg

sudo apt update && sudo apt upgrade -y

mkdir -p ~/ffmpeg_sources ~/bin
export PATH="$HOME/bin:$PATH"

sudo apt install -y \
  autoconf \
  automake \
  build-essential \
  cmake \
  git \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtheora-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  mercurial \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev \
  nasm \
  yasm \
  libvpx-dev \
  libopus-dev \
  libx264-dev \
  libmp3lame-dev \
  libfdk-aac-dev

# Install libaom from source.
# I'll comment this out since it is still unstable
#mkdir -p ~/ffmpeg_sources/libaom && \
#  cd ~/ffmpeg_sources/libaom && \
#  git clone https://aomedia.googlesource.com/aom && \
#  cmake ./aom && \
#  make && \
#  sudo make install

# Install libx265 from source.
cd ~/ffmpeg_sources && \
  git clone https://github.com/videolan/x265 && \
  cd x265/build/linux && \
  cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source && \
  make && \
  make install

cd ~/ffmpeg_sources && \
  wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
  tar xjvf ffmpeg-snapshot.tar.bz2 && \
  cd ffmpeg && \
  PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm" \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libmp3lame \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libtheora \
    --enable-libfreetype \
    --enable-libvorbis \
    --enable-libopus \
    --enable-libvpx \
    --disable-libaom \
    --enable-nonfree && \
  make && \
  make install && \
  hash -r
