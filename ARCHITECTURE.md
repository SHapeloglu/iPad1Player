# iPad1Player Architecture

## Design Goals

iPad1Player is optimized for extreme legacy-device constraints:

- single-core-class iPad 1 hardware
- ~256 MB RAM
- iOS 5.1.1
- armv7
- legacy OpenGL ES 2
- legacy AudioQueue
- non-ARC Objective-C

The architecture prioritizes:

- bounded memory
- predictable CPU load
- minimal copying
- graceful degradation
- separation of suite responsibilities
- real-device compatibility

## High-Level Playback Pipeline

    Local media path
          |
          v
    IP1MediaPreflight
          |
          v
    IP1MKVBackend
          |
          v
    IP1FFmpegAudioSession
          |
          +-----------------------------+
          |                             |
          v                             v
      demux thread                 video worker
      av_read_frame                    |
          |                            |
          |                     IP1FFmpegVideoDecoder
          |                            |
          |                         AVFrame
          |                            |
          |                        YUV420P
          |                            |
          |                     IP1YUVRendererView
          |
          v
    IP1FFmpegAudioDecoder
          |
          v
      SwrContext
          |
          v
    IP1AudioEngine
          |
          v
    IP1PCMRingBuffer
          |
          v
    IP1AudioQueueOutput

## Demux Model

Only one thread owns and calls:

    av_read_frame()

This is a hard architectural rule.

The demux thread routes packets by stream index.

Audio packets remain on the demux/audio path.

Video packets are copied with `av_packet_ref` and transferred to a bounded queue.

## Video Packet Queue

Class:

    IP1PacketQueue

Current video queue policy:

- maximum items: 32
- maximum compressed bytes: 4 MB
- thread-safe
- bounded
- H.264 decode performed by one worker

Random compressed H.264 packet dropping is avoided because reference-frame dependencies can corrupt later decoded pictures.

If the queue temporarily fills, the demux thread yields briefly instead of arbitrarily destroying the H.264 reference chain.

Future timing-based dropping should occur at decoded-frame level where possible, not by randomly discarding compressed reference packets.

## Video Decoder

Class:

    IP1FFmpegVideoDecoder

Current target:

- AV_CODEC_ID_H264
- thread_count = 1
- software decoding
- YUV420P

The decoder retains the most recently decoded AVFrame using `av_frame_ref`.

This is necessary because the working `AVFrame` passed to repeated `avcodec_receive_frame` calls may be reused/unreferenced by FFmpeg.

## Video Renderer

Class:

    IP1YUVRendererView

Technology:

- CAEAGLLayer
- EAGLContext
- OpenGL ES 2
- GL_LUMINANCE textures
- Y/U/V planes
- fragment shader YUV -> RGB

The renderer uses a producer/back buffer and render/front buffer.

Policy:

    newest frame wins

Only one main-thread render request may be scheduled at a time.

This prevents unbounded `performSelectorOnMainThread` buildup.

OpenGL work occurs after the frame-buffer lock is released.

Texture memory is allocated with `glTexImage2D` when size changes.

Normal frame updates use:

    glTexSubImage2D

## Audio Decoder

Class:

    IP1FFmpegAudioDecoder

Supported runtime audio codecs currently include:

- AAC
- MP3

Decoded audio is normalized to:

- 44.1 kHz
- stereo
- signed 16-bit packed PCM

using libswresample.

SwrContext is persistent and rebuilt only if input/output format parameters change.

It must not be recreated for every AAC frame.

## Audio Output

Components:

    IP1AudioEngine
    IP1PCMRingBuffer
    IP1AudioQueueOutput

Current PCM ring:

- 256 KB

AudioQueue:

- three buffers
- 16 KB each
- AVAudioSessionCategoryPlayback
- active AVAudioSession

## Clock

Class:

    IP1PlaybackClock

Audio is intended to be the master clock.

Current decoded-audio clock is based on bytes written into the PCM path and is not yet a true hardware-presentation clock.

This distinction is important for the next A/V synchronization phase.

## Native Playback

MP4/MOV/M4V may use legacy:

    MPMoviePlayerController

where appropriate.

FFmpeg runtime currently primarily targets container/codec combinations that the legacy native path cannot adequately handle.

## Memory Rules

For iPad 1:

- no unbounded packet queues
- no unbounded frame queues
- avoid full RGB frame conversion
- avoid UIImage video rendering
- no large frame history
- prefer 1 latest decoded frame
- keep compressed queues small
- use explicit cleanup under MRC

## Thread Model

Current intended threads:

1. Main/UI thread
   - UIKit
   - OpenGL presentation

2. FFmpeg demux/audio thread
   - `av_read_frame`
   - AAC/MP3 decode
   - PCM enqueue

3. Video decode worker
   - H.264 decode
   - decoded-frame delivery

4. AudioQueue internal callback thread
   - PCM consumption

No second demux reader is permitted.

## Known Technical Debt

- PCM ring is not yet fully thread-safe.
- AudioQueue callback uses KVC to access the PCM ring.
- audio clock is not actual presentation position.
- FFmpeg seek/flush is incomplete.
- video PTS is not yet used for presentation timing.
- EOF needs explicit playback-complete handling.
