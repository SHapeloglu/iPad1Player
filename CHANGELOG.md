# Changelog

## v0.1-alpha18
- Connected av_read_frame to selected AAC/MP3 decode.
- Connected decoded S16 PCM to bounded ring buffer and AudioQueue.
- Added single-thread low-memory demux loop.
- Added PCM occupancy backpressure.
- Added audio master-clock progression.
- Preserved suite responsibility boundaries.

## v0.1-alpha17
- Added low-memory AudioQueue output.
- Added FFmpeg AAC/MP3 decoder source.
- Added 3x16 KB output-buffer policy.
- Kept 256 KB bounded PCM ring buffer.
- Preserved suite responsibility boundaries.
- FFmpeg libraries remain external and device testing is required.

## v0.1-alpha16
- Declared MKV/H.264 playback as explicit Player scope.
- Added centralized H.264 resolution/decode policy.
- Added 360p/480p software test targets.
- Kept 720p software primary path rejected.
- Added legacy hardware/hybrid 720p test gate.
- Added decode capability reporting.

## v0.1-alpha15
- Added code-level suite scope enforcement.
- Added bounded PCM ring buffer.
- Added conservative audio runtime profile.
- Added audio engine boundary.
- Preserved iPad1Files/iPad1PDFReader/iPad1Downloader separation.
- No unsupported decode claim added.

## v0.1-alpha14
- Replaced FFmpeg parse stub with real libavformat parse source behind build flag.
- Added legacy/new FFmpeg AVStream compatibility helpers.
- Added real track/chapter/media-info mapping.
- Added FFmpeg build version reporting.
- Preserved immediate context close and zero-decode parse policy.
- FFmpeg static libraries are intentionally not bundled.

## v0.1-alpha13
- Added file/path preflight validation.
- Added corrupt metadata sanity limits.
- Added bounded parse/close stress-test harness.
- Added MRC-friendly per-iteration autorelease pools.
- Kept codec/decode/render features disabled.

## v0.1-alpha12
- Added FFmpeg build checks.
- Added parse result validation.
- Added parse fallback policy.
- Added strict pre-integration checklist for iPad 1.
- Kept decode/render/audio disabled.

## v0.1-alpha11
- Added parse diagnostics.
- Added parse time and media duration sanity limits.
- Added bounded stream metadata normalization.
- Added parse-and-close runtime contract.
- Kept decode/render/audio disabled.
- Strengthened iPad 1 parse safety gate.

## v0.1-alpha10
- Added centralized iPad 1 memory budgets.
- Reduced compressed packet budgets.
- Added packet-queue trimming under memory pressure.
- Added player low-memory purge.
- Changed default playback rates to safe 0.5x–1.5x profile.
- Tightened parse metadata, track and chapter caps.
- Preserved 2.0x as TEST_REQUIRED instead of default.

## v0.1-alpha9
- Added low-memory parse-only FFmpeg phase contract.
- Added parse-result model for tracks/chapters/media info.
- Added defensive parse policy and limits.
- Added device-test status model.
- Explicitly rejected packet buffering/frame decode during parse-only phase.

## v0.1-alpha8
- Added playback clock model.
- Added video frame render/wait/drop policy.
- Expanded FFmpeg adapter lifecycle.
- Added audio/subtitle track switching contracts.
- Routed MKV backend lifecycle to adapter.
- Documented A/V sync, seek and frame-drop architecture.

## v0.1-alpha7
- Added iPad 1 compatibility gate and status matrix.
- Optimized subtitle lookup to O(1) sequential / O(log n) seek path.
- Reduced resume persistence frequency from 5s to 30s.
- Removed forced NSUserDefaults synchronization.
- Added background/termination resume save.
- Fixed sleep-timer cleanup in MRC lifecycle.
- Added brightness restoration after playback.
- Changed volume gesture to target movie playback.
- Corrected actual playback-speed presets through 2.0x.
- Marked device-sensitive features as TEST_REQUIRED.

## v0.1-alpha6
- Added chapter model.
- Added detailed media-info model.
- Added sleep-timer API.
- Expanded playback-speed target set through 2.0x.
- Extended FFmpeg/MKV backend contracts for chapters and detailed media information.
- Updated sector roadmap priorities.

## v0.1-alpha5
- Added media capability/codec matrix.
- Added FFmpeg adapter boundary.
- Added AVI backend routing path.
- Added bounded FFmpeg packet budgets and seek flush contract.
- Added sector roadmap and codec matrix docs.
- Formalized P0/P1/P2/P3 priorities.
- Formalized legacy-format targets and modern-codec non-goals.

## v0.1-alpha4
- Added MKV backend lifecycle API.
- Added media track model.
- Added bounded packet queue for low-memory operation.
- Added multi-audio / embedded subtitle / delay capability contracts.
- Added decode mode model and legacy-HW capability gate.
- Added optional FFmpeg build hooks.
- Added MKV pipeline, A/V sync and memory-budget documentation.
- Preserved suite responsibility boundaries.

## v0.1-alpha3
- Competitor-inspired playback controls, subtitle UX, gestures, aspect ratios, speed, A-B repeat and media info.
