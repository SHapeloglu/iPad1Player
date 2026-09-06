# iPad1Player v0.1-alpha18

Legacy media player for **iPad 1 / iOS 5.1.1 / armv7 / ~256 MB RAM / Objective-C / UIKit / non-ARC/MRC / Theos**.

## Suite responsibility boundary

iPad1Player only owns **media playback**. It does not duplicate file browsing/management, downloading or PDF reading.

- File management -> `iPad1Files`
- Downloads -> `iPad1Downloader`
- PDF reading -> `iPad1PDFReader`
- Video/audio playback -> `iPad1Player`

See `SUITE_HANDOFF.md` and `docs/RESPONSIBILITY.md`.

## Implemented through alpha4

### Native MP4/MOV/M4V playback
- Apple `MPMoviePlayerController` backend.
- Play/pause/native seek controls.
- Resume from last position; completed media clears resume state.
- Idle sleep disabled during playback.
- Rotation support.

### Seeking and comfort
- Swipe left/right: -10 / +10 seconds.
- Playback speed cycle: 1.0x, 1.25x, 1.5x, 0.5x.
- A-B repeat markers and clear action.
- Control lock.
- Vertical gesture on left half: brightness.
- Vertical gesture on right half: volume.

### Aspect ratio
- Fit
- Fill
- 4:3
- 16:9
- 1.85:1
- 2.35:1

### External subtitles
- `.srt` parsing.
- Automatic sidecar discovery:
  - `Movie.srt`
  - `Movie-tr.srt`
  - `Movie-en.srt`
  - `Movie.tr.srt`
- Cycle between matching external subtitle files.
- Subtitle enable/disable.
- Timing offset in 0.5 second steps.
- Font size adjustment.
- Vertical position adjustment.
- Encoding cycle:
  - Automatic
  - UTF-8
  - Windows-1254
  - ISO-8859-9
- Turkish character support.

### Media information
Native backend displays file/container, resolution, duration and backend type. Codec/track details will be expanded when FFmpeg is linked.

## MKV / FFmpeg backend boundary

`IP1MKVBackend` is now an explicit capability boundary. The UI does not pretend that unavailable FFmpeg-dependent features work.

Still requiring the real legacy FFmpeg/hybrid backend:

- MKV demux/playback.
- AAC/MP3 audio decode from MKV.
- Embedded subtitle tracks.
- ASS/SSA embedded rendering.
- Multiple audio track selection.
- Multiple embedded subtitle track selection.
- Audio delay.
- Detailed codec/fps/bitrate diagnostics.
- Low-memory packet/frame queues.
- H.264 hybrid/hardware-assisted path research for A4/iOS 5.1.1.

> Important: modern VideoToolbox assumptions must not be used for iOS 5.1.1. Any hardware-assisted H.264 path needs to be implemented and tested against the actual legacy device/API constraints.

## External launch

```text
ipad1player://open?path=<percent-encoded-absolute-local-media-path>
```

The player rejects non-media files rather than becoming a file manager.

## Build

```bash
make clean
make package FINALPACKAGE=1
```


## Added in alpha4

- Explicit MKV backend lifecycle contract: open/play/pause/stop/seek/time/duration.
- Track model for video/audio/subtitle streams.
- Multiple-audio and embedded-subtitle selection fields.
- Audio/subtitle delay fields in the backend API.
- Decode mode contract: Automatic / Software / Legacy Hardware.
- Bounded low-memory packet queue implementation.
- FFmpeg build hooks kept optional so the project still builds without vendor libraries.
- MKV pipeline and A/V synchronization design documented in `docs/MKV_BACKEND.md`.

### Not falsely claimed as complete

Real MKV playback is **not** marked complete until compatible FFmpeg armv7 libraries and the adapter are linked and tested on the device. Legacy H.264 hardware acceleration is also not declared supported until verified on an actual iPad 1.


## Added in alpha5 — sector-alignment pass

- Added a centralized capability/codec matrix in code.
- Added AVI as a future FFmpeg-backed container without falsely claiming playback support.
- Added explicit FFmpeg adapter boundary separate from UI and suite routing.
- Added conservative packet budgets for iPad 1 memory limits.
- Added seek-flush contract for FFmpeg playback.
- Added P0/P1/P2/P3 roadmap and codec matrix documentation.
- Added Tier-1 target codecs: H.264 + AAC/MP3 + SRT/ASS/SSA.
- Added Tier-2 targets: AVI + MPEG-4 Part 2/Xvid + AC3/E-AC3.
- Explicitly rejected HEVC/AV1/VP9/4K/HDR for the iPad 1 target.

See:
- `docs/SECTOR_ROADMAP.md`
- `docs/CODEC_MATRIX.md`


## Added in alpha6

- Chapter model and backend contract.
- Detailed media-info model.
- Sleep timer API.
- Expanded playback-speed target set: 0.5x / 0.75x / 1.0x / 1.25x / 1.5x / 2.0x.
- Sector roadmap updated to place chapters and detailed media info in P1, sleep timer and 2.0x speed in P2.
- FFmpeg chapter extraction remains backend-gated and is not falsely marked complete.


## Added in alpha7 — iPad 1 optimization & compatibility pass

- Subtitle lookup changed from full-list scanning to:
  - O(1) fast path during normal sequential playback.
  - O(log n) binary search after seek/jump.
- Resume persistence interval increased from 5 seconds to 30 seconds.
- Forced `NSUserDefaults synchronize` removed.
- Resume state is also saved on app background/termination.
- Sleep timer is invalidated by the common timer cleanup path.
- Original screen brightness is restored after leaving playback if the player changed it.
- Volume gesture now targets the movie player rather than a separate application music player session.
- Playback-speed list now actually contains 0.5x / 0.75x / 1.0x / 1.25x / 1.5x / 2.0x.
- Added code-level `IP1CompatibilityGate`.
- Features are classified as:
  - `IPAD1_SAFE`
  - `IPAD1_TEST_REQUIRED`
  - `IPAD1_REJECTED`

The project must not claim `IPAD1_TEST_REQUIRED` features as proven until tested on a real iPad 1.


## Added in alpha8 — playback engine contract pass

- Added `IP1PlaybackClock`.
- Added `IP1FramePolicy` with Render / Wait / Drop decisions.
- FFmpeg adapter lifecycle now includes play/pause/currentTime/duration.
- Track switching contract now supports audio/subtitle stream selection.
- MKV backend proxies play/pause/stop/seek and track selection to the adapter.
- Added explicit A/V master-clock and late-frame-drop architecture.
- Added `docs/PLAYBACK_ENGINE.md`.

Real FFmpeg demux/decode is still backend-gated; alpha8 does not falsely claim MKV playback is complete.


## Added in alpha9 — constrained FFmpeg parse phase

- Added parse-only FFmpeg contract.
- Added `IP1FFmpegParseResult`.
- Added defensive parse policy for iPad 1.
- Added explicit track/chapter count limits.
- Added device-test status model.
- Alpha9 intentionally does not decode video/audio.
- FFmpeg contexts must be closed immediately after metadata extraction.

See `docs/ALPHA9_PARSE_PHASE.md`.


## Added in alpha10 — iPad 1 hardening

- Central low-memory budget class.
- More conservative FFmpeg packet budgets.
- Queue trimming on memory warning.
- Player-level low-memory purge.
- Safe playback-speed profile capped at 1.5x by default.
- Tighter metadata/track/chapter parse caps.
- Added `docs/ALPHA10_IPAD1_HARDENING.md`.

No new heavy codec feature was added in this pass.


## Added in alpha11 — iPad 1 parse runtime gate

- Added parse diagnostics model.
- Added bounded stream metadata mapper.
- Added parse duration and media-duration sanity limits.
- Added `parseAndCloseMediaAtPath` contract.
- Parse-only backend now explicitly closes state after metadata extraction.
- Added metadata title/language bounding rules.
- No decode/render/audio feature was enabled.

See `docs/ALPHA11_PARSE_RUNTIME_GATE.md`.


## Added in alpha12 — FFmpeg pre-integration gate

- Added build capability reporting.
- Added parse-result validation.
- Added explicit native/FFmpeg fallback policy.
- Added stricter parse rejection behavior.
- Added real iPad 1 integration checklist.
- Still no decode/render/audio enablement.

See `docs/ALPHA12_PREINTEGRATION.md`.


## Added in alpha13 — iPad 1 robustness

- Added media preflight checks.
- Added corrupt/implausible metadata rejection.
- Added bounded repeated parse/close stress-test harness.
- Added per-iteration autorelease-pool draining for MRC.
- No decode/audio/render capability enabled.

See `docs/ALPHA13_ROBUSTNESS.md`.


## Added in alpha14 — real libavformat parse source

When `IP1_FFMPEG_BACKEND` is enabled with compatible armv7 libraries, the adapter now
uses real libavformat APIs to open a container, enumerate tracks, extract chapters and
fill media information, then closes the format context immediately.

- Added old/new FFmpeg stream metadata compatibility helpers.
- Added actual stream and chapter mapping.
- Added FFmpeg version information to build report.
- Added vendor layout documentation.
- Still no H.264/AAC decode or renderer.

See `docs/ALPHA14_REAL_PARSE.md`.


## Added in alpha15 — Player scope + audio foundation

- Added code-level suite responsibility gate.
- Added bounded 256 KB PCM ring buffer.
- Added conservative iPad 1 audio runtime profile.
- Added Player-owned audio engine boundary.
- Explicitly kept Files/PDFReader/Downloader responsibilities out of Player.
- 480p software H.264 remains test-only; 720p software primary path remains rejected.

See `docs/ALPHA15_SCOPE_AND_AUDIO.md`.


## Added in alpha16 — MKV/H.264 iPad 1 policy

- MKV/H.264 playback is now explicitly a Player responsibility.
- Added central H.264 decode decision policy.
- 360p/480p software decode is the intended test target.
- 720p software decode is rejected as a primary path.
- 720p is allowed only through a verified legacy hardware/hybrid path.
- Added video decode capability reporting.

No unsupported decoder was enabled.

See `docs/ALPHA16_H264_POLICY.md`.


## Added in alpha17 — low-memory audio runtime

- Added iOS 5-compatible AudioQueue PCM output.
- Added 3 x 16 KB AudioQueue buffers.
- Retained bounded 256 KB PCM ring buffer.
- Added FFmpeg AAC/MP3 decoder source behind backend flag.
- Added old/new FFmpeg audio decode branches.
- Non-S16 sample formats remain gated pending swresample testing.
- No suite responsibility leakage.

See `docs/ALPHA17_AUDIO_RUNTIME.md`.


## Added in alpha18 — end-to-end audio loop

- Added selected-stream `av_read_frame` loop.
- Added single low-memory audio demux thread.
- Wired AAC/MP3 decoder to bounded PCM ring and AudioQueue.
- Added PCM backpressure before decoding more packets.
- Added audio master-clock progression from accepted PCM bytes.
- Added explicit MKV backend audio-runtime entry points.
- No video decode was enabled.

See `docs/ALPHA18_AUDIO_LOOP.md`.


## Development Documentation

Development and handoff documents:

- `PROJECT_CONTEXT.md` — authoritative current project state
- `ARCHITECTURE.md` — playback and threading architecture
- `SESSION.md` — latest real-device development session
- `TASK.md` — immediate development tasks
- `BACKLOG.md` — prioritized future work
- `SUITE_HANDOFF.md` — suite integration and responsibility handoff
- `docs/RESPONSIBILITY.md` — application responsibility boundaries
