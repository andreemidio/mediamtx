//go:build enable_embedded_ffmpeg && linux

package embeddedffmpeg

import (
	_ "embed"
	"os"
	"path/filepath"
)

//go:embed ffmpeg
var ffmpegBinary []byte

// Instance is an extracted embedded FFmpeg instance.
type Instance struct {
	dir     string
	path    string
	oldPath string
}

// Setup extracts the embedded FFmpeg executable and prepends it to PATH.
func Setup() (*Instance, error) {
	dir, err := os.MkdirTemp("", "mediamtx-ffmpeg-")
	if err != nil {
		return nil, err
	}

	path := filepath.Join(dir, "ffmpeg")

	err = os.WriteFile(path, ffmpegBinary, 0o755)
	if err != nil {
		os.RemoveAll(dir)
		return nil, err
	}

	oldPath := os.Getenv("PATH")
	err = os.Setenv("PATH", dir+string(os.PathListSeparator)+oldPath)
	if err != nil {
		os.RemoveAll(dir)
		return nil, err
	}

	return &Instance{
		dir:     dir,
		path:    path,
		oldPath: oldPath,
	}, nil
}

// Close releases embedded FFmpeg resources.
func (i *Instance) Close() {
	os.Setenv("PATH", i.oldPath) //nolint:errcheck
	os.RemoveAll(i.dir)          //nolint:errcheck
}

// Path returns the path to the embedded FFmpeg executable.
func (i *Instance) Path() string {
	return i.path
}
