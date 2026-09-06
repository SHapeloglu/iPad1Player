# Sector Roadmap

This roadmap converts sector comparison findings into iPad1Player priorities while preserving suite responsibility boundaries.

## P0 — universal-player core

Required before calling the app a real MKV player:
- FFmpeg demux for MKV.
- H.264/AVC video.
- AAC and MP3 audio.
- A/V synchronization.
- bounded low-memory packet queues.
- seek with queue flush.
- 480p and 720p on-device tests.
- software decode fallback.
- legacy hardware H.264 only if verified on iPad 1.

## P1 — track/subtitle parity

- multiple audio tracks.
- embedded SRT.
- ASS/SSA.
- embedded subtitle selection.
- audio delay.
- subtitle delay.
- language/title metadata.
- chapter support.
- detailed media info.

## P2 — useful legacy format expansion

Only after P0/P1 are stable:
- AVI container.
- MPEG-4 Part 2 / Xvid.
- AC3.
- E-AC3.
- richer media info: codec, fps, bitrate, dimensions, sample rate, channels.
- playback speed up to 2.0x.
- sleep timer.

## P3 — optional, performance-gated

- audio boost.
- deinterlace.
- post-processing.

Do not add these if they harm iPad 1 thermals, memory pressure or playback stability.

## Explicit non-goals for iPad 1

- HEVC/H.265
- AV1
- VP9
- 4K
- HDR
- modern 10-bit pipelines

## Suite ownership

- file management -> iPad1Files
- downloads -> iPad1Downloader
- PDF -> iPad1PDFReader
- media playback -> iPad1Player


## Compatibility gate

Sector parity never overrides the iPad 1 target.

Before implementation or release, every feature must be checked against `docs/IPAD1_COMPATIBILITY.md`. Features marked `IPAD1_TEST_REQUIRED` require an on-device iPad 1 test; `IPAD1_REJECTED` features are not implemented.


## alpha8 engine contract

P0 architecture now includes:
- playback master clock model
- frame render/wait/drop policy
- explicit adapter lifecycle
- track-switching contract

This is architecture readiness only. P0 is not complete until real FFmpeg demux/decode and on-device playback tests succeed.
