FROM alpine:3.22 AS build

ARG FFMPEG_VERSION=n8.0
ARG FFMPEG_PREFIX=/opt/ffmpeg-static

RUN apk add --no-cache \
    bash \
    build-base \
    git \
    nasm \
    pkgconf

WORKDIR /tmp

RUN git clone --depth 1 --branch "$FFMPEG_VERSION" https://github.com/FFmpeg/FFmpeg.git ffmpeg

WORKDIR /tmp/ffmpeg

RUN ./configure \
    --prefix="$FFMPEG_PREFIX" \
    --pkg-config-flags="--static" \
    --extra-cflags="-fPIC" \
    --extra-ldflags="-static" \
    --enable-static \
    --disable-shared \
    --disable-autodetect \
    --disable-debug \
    --disable-doc \
    --disable-programs \
    --enable-ffmpeg \
    --enable-ffprobe \
    --enable-pic \
    --enable-pthreads \
    && make -j"$(nproc)" \
    && make install \
    && find "$FFMPEG_PREFIX/lib" -name '*.so*' -delete

RUN sed -i \
    -e 's|^prefix=.*|prefix=${pcfiledir}/../..|' \
    -e 's|^exec_prefix=.*|exec_prefix=${prefix}|' \
    -e 's|^libdir=.*|libdir=${prefix}/lib|' \
    -e 's|^includedir=.*|includedir=${prefix}/include|' \
    "$FFMPEG_PREFIX"/lib/pkgconfig/*.pc

FROM alpine:3.22

COPY --from=build /opt/ffmpeg-static /opt/ffmpeg-static

ENV PATH="/opt/ffmpeg-static/bin:$PATH" \
    PKG_CONFIG_PATH="/opt/ffmpeg-static/lib/pkgconfig"
