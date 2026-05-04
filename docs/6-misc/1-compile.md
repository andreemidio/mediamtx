# Compile from source

## Standard procedure

1. Install git and Go &ge; 1.26.

2. Clone the repository, enter into the folder and start the building process:

   ```sh
   git clone https://github.com/bluenviron/mediamtx
   cd mediamtx
   go generate ./...
   CGO_ENABLED=0 go build .
   ```

   This will produce the `mediamtx` binary.

## Custom libcamera

If you need to use a custom or external libcamera to interact with some Raspberry Pi Camera model that requires it, additional steps are required:

1. Download [mediamtx-rpicamera source code](https://github.com/bluenviron/mediamtx-rpicamera) and compile it against the external libcamera. Instructions are in the repository.

2. Install git and Go &ge; 1.26.

3. Clone the _MediaMTX_ repository:

   ```sh
   git clone https://github.com/bluenviron/mediamtx
   ```

4. Inside the _MediaMTX_ folder, run:

   ```sh
   go generate ./...
   ```

5. Copy `build/mtxrpicam_32` and/or `build/mtxrpicam_64` (depending on the architecture) from `mediamtx-rpicamera` to `mediamtx`, inside folder `internal/staticsources/rpicamera/`, overriding existing folders.

6. Compile:

   ```sh
   go run .
   ```

   This will produce the `mediamtx` binary.

## Cross compile

Cross compilation allows to build an executable for a target machine from another machine with a different operating system or architecture. This is useful in case the target machine doesn't have enough resources for compilation or if you don't want to install the compilation dependencies on it.

1. On the machine you want to use to compile, install git and Go &ge; 1.26.

2. Clone the repository, enter into the folder and start the building process:

   ```sh
   git clone https://github.com/bluenviron/mediamtx
   cd mediamtx
   go generate ./...
   CGO_ENABLED=0 GOOS=my_os GOARCH=my_arch go build .
   ```

   Replace `my_os` and `my_arch` with the operating system and architecture of your target machine. A list of all supported combinations can be obtained with:

   ```sh
   go tool dist list
   ```

   For instance:

   ```sh
   CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build .
   ```

   In case of the `arm` architecture, there's an additional flag available, `GOARM`, that allows to set the ARM version:

   ```sh
   CGO_ENABLED=0 GOOS=linux GOARCH=arm64 GOARM=7 go build .
   ```

   In case of the `mips` architecture, there's an additional flag available, `GOMIPS`, that allows to set additional parameters:

   ```sh
   CGO_ENABLED=0 GOOS=linux GOARCH=mips GOMIPS=softfloat go build .
   ```

   The command will produce the `mediamtx` binary.

## Compile for all supported platforms

Install Docker and launch:

```sh
make binaries
```

The command will produce tarballs in folder `binaries/`.

## Docker image

The official Docker image can be recompiled by following these steps:

1. Build binaries for all supported platforms:

   ```sh
   make binaries
   ```

2. Build the image by using one of the Dockerfiles inside the `docker/` folder:

   ```
   docker build . -f docker/standard.Dockerfile -t my-mediamtx
   ```

   This will produce the `my-mediamtx` image.

   A Dockerfile is available for each image variant (`standard.Dockerfile`, `ffmpeg.Dockerfile`, `rpi.Dockerfile`, `ffmpeg-rpi.Dockerfile`).

## Static FFmpeg libraries

_MediaMTX_ does not link FFmpeg directly. The `ffmpeg` Docker image variant installs FFmpeg as an external command-line tool.

If you need FFmpeg static libraries (`libavcodec.a`, `libavformat.a`, `libavutil.a`, and related headers) for another integration, build them with:

```sh
make ffmpeg-static
```

The command builds FFmpeg in Docker and exports the result to `ffmpeg-static/`. To select a different FFmpeg tag or branch:

```sh
make ffmpeg-static FFMPEG_VERSION=n8.0
```

The generated package includes `include/`, `lib/`, `lib/pkgconfig/`, `bin/ffmpeg`, and `bin/ffprobe`. It uses FFmpeg's built-in components only; external codec libraries are not enabled by default. Link consumers with `pkg-config`, for example:

```sh
PKG_CONFIG_PATH="$PWD/ffmpeg-static/lib/pkgconfig" \
  pkg-config --static --libs libavformat libavcodec libavutil
```

To build a MediaMTX binary that carries its own static FFmpeg executable and makes it available to hooks through `PATH`, run:

```sh
make mediamtx-ffmpeg
```

The command produces `mediamtx-ffmpeg`. At startup, this binary extracts the embedded FFmpeg executable to a temporary directory and prepends that directory to `PATH`, so commands such as `ffmpeg ...` work even when FFmpeg is not installed on the target machine.
