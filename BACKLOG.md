# iPad1Player Backlog

## P0 — Playback Correctness

- [ ] Video PTS extraction
- [ ] Audio-master A/V synchronization
- [ ] Late decoded-frame drop policy
- [ ] Decoder flush at EOF
- [ ] Clean playback-complete event
- [ ] Pause/resume lifecycle validation
- [ ] FFmpeg seek implementation
- [ ] Audio/video decoder flush after seek
- [ ] Packet queue flush after seek

## P1 — Stability

- [ ] Make PCM ring buffer fully thread-safe
- [ ] Remove AudioQueue callback KVC access
- [ ] Propagate AudioQueueStart errors
- [ ] Verify video-worker shutdown race safety
- [ ] Verify repeated open/close playback
- [ ] Verify repeated MKV changes without restarting app
- [ ] Memory-warning behavior
- [ ] 10-minute real-device playback test
- [ ] 30-minute real-device playback test
- [ ] full-movie playback test

## P1 — Video

- [ ] Correct aspect-fit geometry
- [ ] Aspect-fill
- [ ] renderer resize/orientation handling
- [ ] frame timing diagnostics
- [ ] decoded-frame drop statistics
- [ ] packet queue statistics
- [ ] OpenGL error diagnostics
- [ ] YUV color-range handling if needed

## P1 — Audio

- [ ] True AudioQueue presentation clock
- [ ] Audio underrun diagnostics
- [ ] Audio delay control in FFmpeg runtime
- [ ] multiple embedded audio-track switching
- [ ] MP3 runtime validation
- [ ] sample-rate conversion validation

## P2 — Subtitles

- [ ] Integrate existing SRT parser with FFmpeg playback clock
- [ ] subtitle delay
- [ ] subtitle enable/disable
- [ ] embedded subtitle discovery
- [ ] embedded subtitle selection
- [ ] memory-safe subtitle indexing

Heavy ASS rendering is not a project target.

## P2 — Playback UX

- [ ] seek bar connected to FFmpeg runtime
- [ ] resume position
- [ ] chapter navigation
- [ ] playback information overlay
- [ ] audio-track picker
- [ ] subtitle-track picker
- [ ] playback diagnostics screen
- [ ] clean temporary GL diagnostic labels

## P2 — Architecture Cleanup

- [ ] Move video packet wrapper to dedicated source file if needed
- [ ] clarify IP1FFmpegAdapter responsibility
- [ ] replace remaining experimental bypasses
- [ ] update stale Alpha14/Alpha18 comments
- [ ] define production FFmpeg playback interface
- [ ] review stop/dealloc ownership under MRC

## P3 — Compatibility Testing

Real-device test matrix:

- [x] H.264 854x480 + AAC MKV
- [ ] H.264 640x360 + AAC MKV
- [ ] H.264 854x480 + MP3 MKV
- [ ] AVI compatible video/audio
- [ ] variable frame-rate H.264
- [ ] different H.264 profiles within policy
- [ ] malformed media handling

## Explicitly Out of Scope

Do not add:

- HEVC / H.265
- AV1
- VP9
- 4K
- HDR
- 10-bit playback
- cloud file manager
- downloader features
- PDF reader
- general file-manager functionality
- heavy ASS effects
