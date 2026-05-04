# Build estatico e embutido do FFmpeg

Este arquivo registra o que foi feito para permitir compilar o FFmpeg como bibliotecas estaticas e tambem gerar um binario do MediaMTX com o FFmpeg embutido.

## Contexto

O MediaMTX neste repositorio e um projeto Go e nao linka diretamente contra FFmpeg. O FFmpeg aparecia apenas como ferramenta externa:

- em documentacao e exemplos de uso;
- nos testes end-to-end;
- na imagem `docker/ffmpeg.Dockerfile`, instalada via `apk add ffmpeg`.

Por isso, a solucao implementada nao altera o build principal do MediaMTX. Ela adiciona dois fluxos separados:

- um alvo para gerar um pacote local com headers, bibliotecas `.a`, arquivos `pkg-config` e binarios estaticos do FFmpeg;
- um alvo para gerar um binario unico do MediaMTX com o executavel `ffmpeg` embutido.

## Arquivos adicionados ou alterados

- `docker/ffmpeg-static.Dockerfile`: compila o FFmpeg em Alpine com `--enable-static` e `--disable-shared`.
- `scripts/ffmpeg-static.mk`: adiciona o alvo `make ffmpeg-static`.
- `scripts/mediamtx-ffmpeg.mk`: adiciona o alvo `make mediamtx-ffmpeg`.
- `internal/embeddedffmpeg/`: extrai o FFmpeg embutido em runtime e adiciona o diretorio temporario ao `PATH`.
- `Makefile`: lista o alvo `ffmpeg-static` no `make help`.
- `docs/6-misc/1-compile.md`: documenta o novo fluxo.
- `.gitignore`: ignora os artefatos gerados `ffmpeg-static/`, `internal/embeddedffmpeg/ffmpeg` e `mediamtx-ffmpeg`.

## Como compilar

Para gerar apenas o pacote estatico do FFmpeg, execute:

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

## Como gerar o MediaMTX com FFmpeg embutido

Execute:

```sh
make mediamtx-ffmpeg
```

Esse alvo:

1. executa `make ffmpeg-static`;
2. copia `ffmpeg-static/bin/ffmpeg` para `internal/embeddedffmpeg/ffmpeg`;
3. compila o MediaMTX com a build tag `enable_embedded_ffmpeg`;
4. gera o binario final em `mediamtx-ffmpeg`.

Esse binario final contem o executavel `ffmpeg` dentro dele. Quando o MediaMTX inicia, ele extrai o FFmpeg para um diretorio temporario privado e coloca esse diretorio no inicio do `PATH`. Dessa forma, hooks e comandos configurados como `ffmpeg ...` encontram o FFmpeg embutido mesmo em uma maquina sem FFmpeg instalado.

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

Para o binario embutido, a validacao esperada e:

```sh
make mediamtx-ffmpeg
./mediamtx-ffmpeg
```

Nos logs de inicializacao deve aparecer uma linha parecida com:

```text
embedded FFmpeg available at /tmp/mediamtx-ffmpeg-.../ffmpeg
```

## Observacoes

O build usa apenas componentes internos do FFmpeg por padrao. Bibliotecas externas de codec, como x264, x265, libvpx ou outras, nao foram habilitadas nesta primeira versao.

O suporte de FFmpeg embutido foi implementado para Linux, porque o executavel FFmpeg empacotado por este fluxo e Linux. O build padrao do MediaMTX continua funcionando sem embutir FFmpeg.
