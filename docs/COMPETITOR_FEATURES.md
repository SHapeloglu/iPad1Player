# Competitor-derived Player Feature Log

This file records competitor-inspired features accepted for iPad1Player after the suite responsibility filter.

## Implemented through alpha4

- External SRT auto-match and language-suffixed sidecars.
- Subtitle enable/disable.
- Subtitle delay.
- Subtitle font size and vertical position.
- Manual subtitle encoding selection.
- Resume playback.
- +/-10 second gesture seek.
- Detailed aspect ratio presets.
- Playback speed.
- A-B repeat.
- Brightness gesture.
- Volume gesture.
- Playback control lock.
- Basic media info.

## Requires MKV backend

- MKV demux/playback.
- Multiple audio tracks.
- Embedded subtitle tracks.
- ASS/SSA support.
- Audio delay.
- Hardware-assisted H.264 path.
- Detailed codec/fps/bitrate information.

## Explicitly rejected from Player

- File browser, rename, move, copy, delete, folders, archives -> iPad1Files.
- Download queue / HTTP-FTP download management -> iPad1Downloader.
- PDF view/read/bookmark -> iPad1PDFReader.


## Alpha4 backend work

Implemented as real architecture/code boundaries:
- bounded packet queue
- media track model
- multi-audio selection contract
- embedded-subtitle selection contract
- audio delay contract
- subtitle delay contract
- decode-mode contract
- media-info backend contract
- FFmpeg optional-build hooks

Still requires actual vendor/runtime implementation:
- FFmpeg demux/decode
- AAC/MP3 decode from MKV
- embedded subtitle extraction/rendering
- verified legacy hardware H.264 path
