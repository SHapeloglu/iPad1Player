# MKV / FFmpeg Backend Plan — alpha4

## Goal

Make iPad1Player's first real MKV backend without duplicating responsibilities from iPad1Files, iPad1Downloader or iPad1PDFReader.

Target:
- iPad 1
- iOS 5.1.1
- armv7
- ~256 MB RAM
- non-ARC/MRC
- legacy iPhoneOS 6.1 SDK

## Pipeline

MKV -> FFmpeg demux -> bounded packet queues -> video/audio decoders -> A/V clock -> renderer/audio output

### Video
Priority:
1. H.264 stream detection.
2. Legacy hardware-assisted path only when verified on a real iPad 1.
3. Software decode fallback.
4. Drop late frames rather than allowing an unbounded queue.

### Audio
Initial codecs:
- AAC
- MP3

Audio becomes the preferred master clock when available.

### Synchronization
- Audio clock is master when audio is active.
- Video frame too early -> short wait.
- Video frame too late -> drop.
- Subtitle clock follows presentation time plus user subtitle offset.
- Audio delay is represented in backend API and is applied in the audio clock/output path once FFmpeg audio is active.

## Low-memory limits

The queue implementation is intentionally bounded.

Recommended starting budget:
- compressed video packets: <= 4 MB
- compressed audio packets: <= 1 MB
- decoded video frames: <= 3 frames
- decoded audio: short rolling buffer only

Never cache the entire MKV file or an unbounded subtitle/frame history.

## Track model

`IP1MediaTrack` represents:
- video
- audio
- subtitle

The backend contract already supports:
- multiple audio tracks
- multiple embedded subtitle tracks
- selected audio/subtitle track
- audio delay
- subtitle delay
- decode mode

## Build flags

The source stays buildable without FFmpeg.

Enable adapter code only when legacy armv7 libraries are actually linked:

```make
iPad1Player_CFLAGS += -DIP1_FFMPEG_BACKEND
```

Do not enable `IP1_LEGACY_H264_HW` until a real iPad 1 test confirms the hardware path.

## Important compatibility rule

Do not assume modern VideoToolbox APIs exist on iOS 5.1.1. Hardware-assisted H.264 must be based on APIs actually available on the target device/SDK and proven with an on-device test.
