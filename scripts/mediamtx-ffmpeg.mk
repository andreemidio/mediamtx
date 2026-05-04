MEDIAMTX_FFMPEG_BINARY ?= mediamtx-ffmpeg
MEDIAMTX_FFMPEG_TAGS ?= enable_embedded_ffmpeg

.PHONY: mediamtx-ffmpeg
mediamtx-ffmpeg: ffmpeg-static
	cp ffmpeg-static/bin/ffmpeg internal/embeddedffmpeg/ffmpeg
	go generate ./...
	CGO_ENABLED=0 go build -tags "$(MEDIAMTX_FFMPEG_TAGS)" -o "$(MEDIAMTX_FFMPEG_BINARY)" .
