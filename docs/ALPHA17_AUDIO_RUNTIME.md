# Alpha17 — iPad 1 Audio Runtime

Alpha17 implements Player-owned audio runtime pieces only.

## Added

### AudioQueue output
- iOS 5-compatible AudioQueue API
- 16 KB output buffers
- 3 queue buffers (~48 KB AudioQueue payload)
- bounded 256 KB PCM ring buffer
- 16-bit signed stereo baseline
- 44.1 kHz conservative default

### FFmpeg AAC/MP3 decoder source
When `IP1_FFMPEG_BACKEND` is linked:
- AAC decoder lookup
- MP3 decoder lookup
- legacy/new FFmpeg decode API branches
- packed S16 PCM output path

Non-S16 FFmpeg sample formats are deliberately rejected until `swresample`
is introduced and tested on iPad 1.

## Scope filter

All work in this release belongs to iPad1Player:
- audio decode
- PCM buffering
- audio device output
- audio clock foundation

No change is required in:
- iPad1Files
- iPad1PDFReader
- iPad1Downloader

## Important limitations

This source package still does not bundle FFmpeg armv7 static libraries.
The decoder source therefore becomes active only when the verified backend is linked.

The demux loop is not yet wired to feed decoded AAC/MP3 packets continuously.
Alpha17 provides the real decoder/output components required for that next integration.
