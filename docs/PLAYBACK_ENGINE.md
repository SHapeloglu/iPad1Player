# Playback Engine Contract — alpha8

## P0 lifecycle

The FFmpeg-backed engine now has explicit lifecycle methods:

1. `open`
2. `play`
3. `pause`
4. `seek`
5. `close`

The adapter owns:
- bounded video packet queue
- bounded audio packet queue
- playback clock
- track list
- chapter list
- media info

The source remains buildable without FFmpeg.

## A/V clock

Preferred master:
1. audio clock when audio exists
2. video clock when there is no audio
3. external clock only for exceptional cases

`IP1PlaybackClock` centralizes time state.

## Frame scheduling

`IP1FramePolicy` returns:
- Render
- Wait
- Drop

Policy:
- frame too early -> wait briefly
- frame on time -> render
- frame too late -> drop

This prevents latency and memory growth on iPad 1.

Recommended initial thresholds for device testing:
- early tolerance: ~20 ms
- late tolerance: ~80–120 ms

These are test values, not guaranteed final constants.

## Seek

Seek must:
1. pause demux/decode work
2. flush compressed packet queues
3. flush decoded frame/audio buffers
4. seek demuxer to keyframe
5. reset playback clocks
6. resume decode

The current adapter already exposes the queue-flush contract.

## Track switching

The adapter contract supports:
- select audio stream by stream index
- select subtitle stream by stream index
- subtitle off using stream index `-1`

Real codec flush/reopen behavior is implemented only when FFmpeg is linked.

## iPad 1 limits

Never:
- use an unbounded queue
- cache the full media file
- use 720p software H.264 as the primary path
- claim legacy hardware H.264 without real-device verification
