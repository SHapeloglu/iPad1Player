# Development Session

## Session: Working FFmpeg Video Playback on Real iPad 1

This session converted the existing FFmpeg audio runtime into a functioning audio/video MKV playback pipeline on a real iPad 1.

## Starting State

The project already had:

- FFmpeg 4.4 armv7 static libraries
- MKV parsing
- AAC/MP3 audio decode
- swresample
- AudioQueue output
- working audible MKV audio

Video had no renderer.

The original movie used for initial testing was:

- HEVC
- 1280x720
- AAC

HEVC/720p is outside project scope.

A dedicated test file was therefore prepared:

- H.264 Main
- 854x480
- yuv420p
- AAC LC
- 44.1 kHz stereo
- MKV

## H.264 Decode Verification

A diagnostic H.264 decoder was added.

Real-device result demonstrated decoded frames such as:

    Video 75 frame 854x480

This proved H.264 software decode worked on iPad 1.

## OpenGL ES 2 Renderer

Added:

    IP1YUVRendererView.h
    IP1YUVRendererView.m

Renderer:

- accepts YUV420P
- copies Y/U/V planes safely
- uploads three GL_LUMINANCE textures
- converts YUV to RGB in shader
- presents with CAEAGLLayer

Initial screen remained black.

## AVFrame Lifetime Bug

Decoded frame count increased but no YUV callback reached the renderer.

Cause:

The decoder exposed `_frame` after repeated `avcodec_receive_frame()` calls.

The working AVFrame could be reused/unreferenced.

Fix:

- introduced `_lastFrame`
- `av_frame_ref(_lastFrame, _frame)`
- renderer reads from the retained frame

Result:

Real video image appeared successfully on the physical iPad 1.

## Renderer Backpressure

Initial playback later showed freezes affecting both audio and video.

Cause:

- too many main-thread render requests
- GL work while frame lock held
- demux thread could be blocked

Fix:

- producer/render double-buffer
- `_drawScheduled`
- only one outstanding UI render request
- newest-frame-wins policy
- release lock before OpenGL work

Result:

Playback progressed much more reliably.

## Texture Upload Optimization

Initial renderer used `glTexImage2D` for every frame.

Changed to:

- `glTexImage2D` only for allocation/size change
- `glTexSubImage2D` for normal frame updates

This reduced unnecessary texture recreation, although it did not alone remove all micro-stutter.

## Persistent SwrContext

Audio decoder previously performed:

    swr_free
    swr_alloc_set_opts
    swr_init

for every decoded audio frame.

Changed to persistent SwrContext.

The context is rebuilt only when:

- input layout changes
- input sample format changes
- input rate changes
- output layout/rate/channels change

This was correct optimization but was not the main remaining stutter cause.

## Separate Video Decode Worker

The important performance problem was architectural.

Previously:

    av_read_frame
      -> H264 decode
      -> AAC decode

Video decode latency delayed audio packet processing.

Implemented:

    single av_read_frame
          |
          +-> audio decode
          |
          +-> bounded video packet queue
                    |
                    v
              video worker
                    |
                    v
               H264 decode

Result:

Micro-freezes disappeared.

## H.264 Packet Corruption

Initial worker queue was small and dropped compressed H.264 packets when full.

Playback became smooth but video showed severe corruption/blocking.

Cause:

Random compressed H.264 packet loss breaks inter-frame reference dependencies.

Fix:

- queue increased to 32 packets
- 4 MB compressed byte bound
- arbitrary H.264 packet dropping removed
- brief retry/yield when queue is full

Result:

Real-device test:

- smooth playback
- clean image
- audio continues correctly
- no earlier micro-freezes

## Current Verified Milestone

The following pipeline now works on a real iPad 1:

    MKV
      |
    FFmpeg demux
      |
      +--> AAC --> PCM --> AudioQueue
      |
      +--> bounded H264 packet queue
               |
          video worker
               |
           H264 decode
               |
            YUV420P
               |
          OpenGL ES 2
               |
            display

## Next Development Area

Do not immediately add unrelated features.

Next priority:

A/V synchronization using:

- video PTS
- audio master clock
- frame scheduling
- late-frame handling
