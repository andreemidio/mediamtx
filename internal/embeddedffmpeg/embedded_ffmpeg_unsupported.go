//go:build enable_embedded_ffmpeg && !linux

package embeddedffmpeg

import "fmt"

// Instance is an extracted embedded FFmpeg instance.
type Instance struct{}

// Setup initializes embedded FFmpeg, when enabled at build time.
func Setup() (*Instance, error) {
	return nil, fmt.Errorf("embedded FFmpeg is supported only on Linux")
}

// Close releases embedded FFmpeg resources.
func (i *Instance) Close() {}

// Path returns the path to the embedded FFmpeg executable.
func (i *Instance) Path() string {
	return ""
}
