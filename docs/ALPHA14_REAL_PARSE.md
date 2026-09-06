# Alpha14 — Real libavformat Parse Path

Alpha14 replaces the FFmpeg parse stub with a real libavformat parse implementation
when `IP1_FFMPEG_BACKEND` is enabled.

## Real API path

- `avformat_open_input`
- `avformat_find_stream_info`
- stream enumeration
- `avcodec_get_name`
- stream language/title metadata
- container name
- duration / bitrate
- video width / height / FPS
- audio sample rate / channels
- chapter extraction
- `avformat_close_input`

## Legacy FFmpeg compatibility

`IP1FFmpegCompat.h` hides the old `AVStream.codec` versus newer
`AVStream.codecpar` difference.

This lets the project test a legacy FFmpeg build appropriate for iOS 5.1.1
without coupling the player code to only a modern FFmpeg API.

## iPad 1 rules preserved

Parse-only mode:
- opens no decoder
- starts no decoder threads
- queues no packets
- allocates no decoded frames
- closes `AVFormatContext` before return

Existing limits remain active:
- max 24 tracks
- max 128 chapters
- metadata validation
- corrupt-file preflight
- parse diagnostics
- repeated parse/close test harness

## Important

The source code now contains a real libavformat parse path, but the ZIP intentionally
does not ship FFmpeg static libraries.

Therefore:
- build without `IP1_FFMPEG_BACKEND` remains functional for native player paths
- real MKV metadata parsing becomes active only after compatible armv7 static FFmpeg
  libraries are supplied and the build flag is enabled

No video/audio decoding is enabled in alpha14.
