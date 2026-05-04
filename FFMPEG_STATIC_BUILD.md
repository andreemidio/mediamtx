# Build estatico do FFmpeg

Este arquivo registra o que foi feito para permitir compilar o FFmpeg como bibliotecas estaticas dentro deste repositorio.

## Contexto

O MediaMTX neste repositorio e um projeto Go e nao linka diretamente contra FFmpeg. O FFmpeg aparecia apenas como ferramenta externa:

- em documentacao e exemplos de uso;
- nos testes end-to-end;
- na imagem `docker/ffmpeg.Dockerfile`, instalada via `apk add ffmpeg`.

Por isso, a solucao implementada nao altera o build principal do MediaMTX. Ela adiciona um alvo separado para gerar um pacote local com headers, bibliotecas `.a`, arquivos `pkg-config` e binarios estaticos do FFmpeg.

## Arquivos adicionados ou alterados

- `docker/ffmpeg-static.Dockerfile`: compila o FFmpeg em Alpine com `--enable-static` e `--disable-shared`.
- `scripts/ffmpeg-static.mk`: adiciona o alvo `make ffmpeg-static`.
- `Makefile`: lista o alvo `ffmpeg-static` no `make help`.
- `docs/6-misc/1-compile.md`: documenta o novo fluxo.
- `.gitignore`: ignora o diretorio gerado `ffmpeg-static/`.

## Como compilar

Execute:

```sh
make ffmpeg-static
```

Por padrao, o alvo compila o tag `n8.0` do FFmpeg. Para usar outro tag ou branch:

```sh
make ffmpeg-static FFMPEG_VERSION=n8.0
```

O resultado e exportado para:

```text
ffmpeg-static/
```

Esse diretorio e gerado localmente e nao deve ser versionado.

## Artefatos gerados

O pacote exportado contem:

- `ffmpeg-static/include/`
- `ffmpeg-static/lib/`
- `ffmpeg-static/lib/pkgconfig/`
- `ffmpeg-static/bin/ffmpeg`
- `ffmpeg-static/bin/ffprobe`

As bibliotecas estaticas principais geradas foram:

- `libavcodec.a`
- `libavdevice.a`
- `libavfilter.a`
- `libavformat.a`
- `libavutil.a`
- `libswresample.a`
- `libswscale.a`

## Como linkar em outro consumidor

Use os arquivos `pkg-config` gerados:

```sh
PKG_CONFIG_PATH="$PWD/ffmpeg-static/lib/pkgconfig" \
  pkg-config --static --libs libavformat libavcodec libavutil
```

Os arquivos `.pc` foram ajustados para serem relocaveis dentro do diretorio `ffmpeg-static/`, sem depender de `/opt/ffmpeg-static` no host.

## Validacoes feitas

Foi executado:

```sh
make ffmpeg-static
```

E validado que:

- o build gera bibliotecas `.a`;
- nao ha arquivos `.so` dentro de `ffmpeg-static/`;
- `ffmpeg-static/bin/ffmpeg` e um executavel estaticamente linkado;
- `ldd ffmpeg-static/bin/ffmpeg` retorna `not a dynamic executable`;
- `pkg-config --static` resolve os caminhos a partir do pacote local.

## Observacoes

O build usa apenas componentes internos do FFmpeg por padrao. Bibliotecas externas de codec, como x264, x265, libvpx ou outras, nao foram habilitadas nesta primeira versao.
