# Alpha16 — iPad 1 MKV/H.264 Playback Policy

MKV + H.264 playback is explicitly an iPad1Player responsibility.

Alpha16 does not enable a decoder yet; it defines the runtime decision policy that
future FFmpeg decode must obey.

## Safe target

Software H.264 test target:
- 360p class
- 480p class
- up to roughly 854x480

Status:
- TEST_REQUIRED until real-device playback passes
- intended primary software path

## 720p

720p-class H.264:
- software decode is NOT a primary path
- allowed only through a verified legacy hardware/hybrid decode path
- remains TEST_REQUIRED
- `IP1_LEGACY_H264_HW` must not be enabled without an actual iPad 1 test

## Above 720p

Rejected for normal iPad 1 playback.

## Why

The goal is not to reject MKV/H.264. The goal is to select the decode method based on
the A4 CPU and ~256 MB RAM limits.

Container parsing and H.264 playback are separate concerns:
- MKV demux is lightweight enough
- H.264 decode cost depends heavily on resolution/profile/bitrate

## Player scope

Owned by iPad1Player:
- MKV demux
- H.264 decode
- renderer
- A/V sync
- frame drop
- audio decode/output
- subtitle/audio track selection

Not owned:
- file browsing/management -> iPad1Files
- PDF/document reading -> iPad1PDFReader
- downloads -> iPad1Downloader
