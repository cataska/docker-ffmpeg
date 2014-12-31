FROM ubuntu:14.04
MAINTAINER cataska

RUN apt-get update && \
    apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
    libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libx11-dev \
    libxext-dev libxfixes-dev pkg-config texi2html zlib1g-dev \
    wget unzip yasm libx264-dev libmp3lame-dev libopus-dev && \
    mkdir ~/ffmpeg_sources

# Build libfdk-aac
RUN cd ~/ffmpeg_sources && \
    wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master && \
    unzip fdk-aac.zip && \
    cd mstorsjo-fdk-aac* && \
    autoreconf -fiv && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
    make && \
    make install && \
    make distclean

# Build libvpx
RUN cd ~/ffmpeg_sources && \
    wget http://webm.googlecode.com/files/libvpx-v1.3.0.tar.bz2 && \
    tar xjvf libvpx-v1.3.0.tar.bz2 && \
    cd libvpx-v1.3.0 && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make clean

# Build ffmpeg
RUN cd ~/ffmpeg_sources && \
    wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar xjvf ffmpeg-snapshot.tar.bz2 && \
    cd ffmpeg && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-nonfree \
    --enable-x11grab && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean && \
    hash -r

CMD ffmpeg
