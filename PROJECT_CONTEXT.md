# iPad1Player — Project Context

> This document is the authoritative handoff document for continuing development.

## Project

iPad1Player is a media player designed specifically for:

- iPad 1
- iOS 5.1.1
- armv7
- approximately 256 MB RAM
- Objective-C / UIKit
- non-ARC / manual retain-release
- Theos
- legacy iPhoneOS 6.1 SDK

The project intentionally targets hardware and operating-system constraints that modern media players no longer support.

## Suite Responsibility

iPad1Player is one application in the legacy iPad 1 application suite.

Responsibilities:

- iPad1Files
  - file browsing
  - search
  - sort
  - favorites
  - copy/move/delete/rename
  - folders
  - archives
  - file information

- iPad1Downloader
  - HTTP/HTTPS/FTP downloads
  - queue
  - progress
  - resume
  - retry

- iPad1PDFReader
  - PDF rendering
  - navigation
  - reading
  - PDF bookmarks

- iPad1Player
  - demux
  - audio/video decode
  - audio/video output
  - A/V synchronization
  - seek
  - resume
  - playback controls
  - subtitles
  - track selection
  - delay controls
  - chapters
  - media information
  - playback diagnostics
  - codec compatibility
  - memory-safe buffering

Do not move file-manager, downloader or PDF-reader responsibilities into iPad1Player.

See:

- `SUITE_HANDOFF.md`
- `docs/RESPONSIBILITY.md`

## URL Scheme

Player open URL:

    ipad1player://open?path=<percent-encoded-local-path>

The local path is supplied by another suite application such as iPad1Files.

## Current Verified Playback State

Real iPad 1 device testing has verified:

- MKV container parsing
- FFmpeg demux
- AAC audio decode
- swresample conversion
- 44.1 kHz stereo signed 16-bit PCM output
- AudioQueue playback
- H.264 software decode at 854x480
- YUV420P AVFrame output
- OpenGL ES 2 YUV renderer
- Y/U/V texture upload
- shader-based YUV to RGB conversion
- CAEAGLLayer presentation
- simultaneous audio and video playback
- bounded compressed-video packet queue
- dedicated H.264 video decode worker
- one and only one `av_read_frame` demux reader
- persistent SwrContext
- latest-frame renderer backpressure
- stable 480p test playback without the earlier micro-freezes

Real-device test profile:

- H.264 Main
- 854x480
- yuv420p
- AAC LC
- 44.1 kHz
- stereo
- MKV

## Codec Policy

### Supported / targeted

- H.264 software decode up to 854x480:
  `IPAD1_TEST_REQUIRED`

- AAC
- MP3
- MKV demux
- AVI demux where compatible
- native MP4/MOV/M4V path through legacy MediaPlayer where appropriate

### Not targeted

- HEVC / H.265
- AV1
- VP9
- 4K
- HDR
- 10-bit video
- heavy ASS rendering
- modern hardware-only formats

H.264 720p software remains rejected.

## Playback Architecture

Current architecture:

    AVFormatContext
          |
          | one av_read_frame thread
          |
          +---- AAC packets
          |        |
          |        v
          |   AAC decoder
          |        |
          |   persistent swresample
          |        |
          |   PCM ring
          |        |
          |   AudioQueue
          |
          +---- H.264 packets
                   |
                   v
            bounded packet queue
                   |
                   v
            video decode worker
                   |
                   v
              YUV420P frame
                   |
                   v
          latest-frame renderer
                   |
                   v
             OpenGL ES 2

There must never be two independent `av_read_frame` readers for the same playback session.

## Important Current Limitations

The current playback implementation is not considered feature complete.

Still missing or incomplete:

- real A/V synchronization
- video PTS scheduling
- true AudioQueue presentation clock
- robust seek/flush
- EOF handling
- clean end-of-playback state
- long-duration stability validation
- production subtitle integration with FFmpeg playback
- embedded subtitle selection
- audio-track switching
- complete pause/resume semantics
- proper frame-drop policy based on timing
- diagnostics cleanup
- thread-safe PCM ring-buffer implementation
- removal of AudioQueue KVC access
- FFmpeg adapter general playback path

## Current Priority

Immediate next action:

Implement timestamp-aware A/V synchronization using:

- audio as master clock
- video PTS
- bounded video scheduling
- controlled late-frame dropping

Do not begin unrelated features before the playback timing path is stable.

## Real Device

Development/testing device:

- iPad 1
- iOS 5.1.1
- armv7

Legacy SSH requires ssh-rsa compatibility options.

## Development Rule

For every feature:

1. Apply suite responsibility filter.
2. Check iPad 1 CPU/RAM impact.
3. Prefer bounded memory.
4. Avoid unbounded queues.
5. Avoid unnecessary copies.
6. Test on the real iPad.
7. Do not mark a feature working solely because it compiles.
