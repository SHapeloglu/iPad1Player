# Alpha6 sector-alignment additions

## Chapters
A lightweight `IP1Chapter` model now exists. FFmpeg extraction is intentionally deferred until the backend is linked.

Expected chapter fields:
- start time
- title

## Sleep timer
Player API supports minute-based sleep timer. Recommended UI presets:
- Off
- 15 min
- 30 min
- 45 min
- 60 min
- End of media (future backend-aware option)

## Playback speed
Target presets:
- 0.5x
- 0.75x
- 1.0x
- 1.25x
- 1.5x
- 2.0x

Higher speeds are intentionally not prioritized on iPad 1.

## Detailed media info
`IP1MediaInfo` tracks:
- container
- video codec
- audio codec
- dimensions
- fps
- bitrate
- audio sample rate
- channels
- duration

The native backend can fill what iOS 5 exposes. The FFmpeg backend will fill the full set once linked.

## Still backend-gated
- chapter extraction from MKV/AVI
- embedded subtitle enumeration
- multiple audio track enumeration
- audio delay application
- codec/fps/bitrate extraction from FFmpeg
