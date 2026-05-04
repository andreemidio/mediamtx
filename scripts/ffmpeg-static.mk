FFMPEG_VERSION ?= n8.0
FFMPEG_STATIC_IMAGE ?= mediamtx-ffmpeg-static
FFMPEG_STATIC_DIR ?= ffmpeg-static

.PHONY: ffmpeg-static
ffmpeg-static:
	docker build . \
		-f docker/ffmpeg-static.Dockerfile \
		--build-arg FFMPEG_VERSION=$(FFMPEG_VERSION) \
		-t $(FFMPEG_STATIC_IMAGE)
	docker run --rm -v "$(shell pwd):/out" \
		$(FFMPEG_STATIC_IMAGE) \
		sh -c "rm -rf /out/$(FFMPEG_STATIC_DIR) && mkdir -p /out/$(FFMPEG_STATIC_DIR) && cp -R /opt/ffmpeg-static/. /out/$(FFMPEG_STATIC_DIR)/ && chown -R $(shell id -u):$(shell id -g) /out/$(FFMPEG_STATIC_DIR)"
