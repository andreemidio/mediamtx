//go:build !enable_embedded_ffmpeg

package embeddedffmpeg

// Instance is an extracted embedded FFmpeg instance.
type Instance struct{}

// Setup initializes embedded FFmpeg, when enabled at build time.
func Setup() (*Instance, error) {
	return nil, nil
}

// Close releases embedded FFmpeg resources.
func (i *Instance) Close() {}

// Path returns the path to the embedded FFmpeg executable.
func (i *Instance) Path() string {
	return ""
}
