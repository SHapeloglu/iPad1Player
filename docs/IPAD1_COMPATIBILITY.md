# iPad 1 Compatibility Gate

Target:
- iPad 1 / A4
- iOS 5.1.1
- armv7
- ~256 MB RAM
- Objective-C / UIKit
- non-ARC/MRC
- Theos / legacy iPhoneOS 6.1 SDK

Every new feature must pass these checks before it is considered complete:

1. API exists on iOS 5.1.1.
2. armv7 build succeeds.
3. MRC ownership/lifecycle is safe.
4. Peak memory is bounded.
5. Continuous CPU cost is acceptable.
6. It does not add unnecessary work to the decode/render loop.
7. Per-frame allocations are minimized.
8. Disk I/O is minimized.
9. Real iPad 1 test status is recorded.
10. A lighter implementation was considered.

## Status meanings

### IPAD1_SAFE
Architecture/API/cost is suitable for iPad 1 and does not require unusual device-specific performance assumptions.

### IPAD1_TEST_REQUIRED
The feature is allowed in source but cannot be claimed as proven until tested on the real device.

### IPAD1_REJECTED
The feature is intentionally excluded for the iPad 1 target.

## Current matrix

| Feature | Status |
|---|---|
| External SRT | IPAD1_SAFE |
| Subtitle delay/size/position | IPAD1_SAFE |
| Resume | IPAD1_SAFE |
| Chapters model | IPAD1_SAFE |
| Sleep timer | IPAD1_SAFE |
| Gesture seek | IPAD1_SAFE |
| MKV demux | IPAD1_SAFE |
| Bounded packet queues | IPAD1_SAFE |
| 2.0x playback | IPAD1_TEST_REQUIRED |
| Volume gesture | IPAD1_TEST_REQUIRED |
| Basic ASS/SSA | IPAD1_TEST_REQUIRED |
| AC3/E-AC3 | IPAD1_TEST_REQUIRED |
| 720p legacy hardware H.264 | IPAD1_TEST_REQUIRED |
| 480p software H.264 | IPAD1_TEST_REQUIRED |
| 720p software H.264 as primary path | IPAD1_REJECTED |
| HEVC/H.265 | IPAD1_REJECTED |
| AV1 | IPAD1_REJECTED |
| VP9 | IPAD1_REJECTED |
| 4K | IPAD1_REJECTED |
| HDR | IPAD1_REJECTED |
| Modern 10-bit video pipeline | IPAD1_REJECTED |

## alpha7 optimizations

### Subtitle
Previous behavior could scan every SRT cue every 100 ms.

New behavior:
- normal playback: checks current/next cue only.
- seek/jump: binary search.

### Resume
Previous:
- save every 5 seconds
- explicit synchronize

New:
- save every 30 seconds
- save on pause/stop/background/termination
- no forced synchronize

### Timers
Subtitle, resume and sleep timers all pass through one cleanup path.

### Brightness
Player stores the original brightness and restores it when leaving playback if the gesture changed it.

### Volume
The gesture no longer controls `applicationMusicPlayer`; it targets the movie playback object. This remains `IPAD1_TEST_REQUIRED`.

## Hardware decode rule

Never define or advertise legacy H.264 hardware decode support until a real iPad 1 test proves it.

Modern VideoToolbox assumptions are not accepted for iOS 5.1.1.


## Alpha9 parse-only decisions

| Feature | Status |
|---|---|
| Parse-only FFmpeg metadata | IPAD1_TEST_REQUIRED |
| Track enumeration | IPAD1_TEST_REQUIRED |
| Chapter extraction | IPAD1_TEST_REQUIRED |
| Detailed media info extraction | IPAD1_TEST_REQUIRED |
| Parse-time packet buffering | IPAD1_REJECTED |
| Parse-time frame decode | IPAD1_REJECTED |

The parser must release FFmpeg contexts immediately after metadata extraction.


## Alpha10 hardening decisions

| Feature | Status |
|---|---|
| Memory warning purge | IPAD1_SAFE |
| Conservative memory budgets | IPAD1_SAFE |
| Safe rate profile through 1.5x | IPAD1_SAFE |
| 2.0x playback | IPAD1_TEST_REQUIRED |
| Parse-only FFmpeg integration | IPAD1_TEST_REQUIRED |

Alpha10 prioritizes stability over feature count.


## Alpha11 parse runtime gate

| Feature | Status |
|---|---|
| Parse context close immediately after metadata | IPAD1_SAFE |
| Metadata/track/chapter defensive limits | IPAD1_SAFE |
| Real libavformat parse | IPAD1_TEST_REQUIRED |
| Stream enumeration | IPAD1_TEST_REQUIRED |
| Chapter extraction | IPAD1_TEST_REQUIRED |
| Detailed media info extraction | IPAD1_TEST_REQUIRED |

No decode capability changes in alpha11.


## Alpha12 pre-integration gate

| Feature | Status |
|---|---|
| FFmpeg build capability check | IPAD1_SAFE |
| Parse result validator | IPAD1_SAFE |
| Parse fallback policy | IPAD1_SAFE |
| Real armv7 FFmpeg link | IPAD1_TEST_REQUIRED |
| Release enablement of FFmpeg backend | IPAD1_TEST_REQUIRED |

Decode/render remains unchanged.


## Alpha13 robustness decisions

| Feature | Status |
|---|---|
| Media path/file preflight | IPAD1_SAFE |
| Corrupt metadata sanity validation | IPAD1_SAFE |
| 10-cycle parse/close stress harness | IPAD1_SAFE |
| 25-cycle maximum test harness | IPAD1_SAFE |
| Real memory-leak verdict | IPAD1_TEST_REQUIRED |

No codec/decode capability was enabled.


## Alpha14 real parse implementation

| Feature | Status |
|---|---|
| libavformat parse source implementation | IPAD1_TEST_REQUIRED |
| Stream enumeration implementation | IPAD1_TEST_REQUIRED |
| Chapter extraction implementation | IPAD1_TEST_REQUIRED |
| Media-info mapping implementation | IPAD1_TEST_REQUIRED |
| Parse-time decoder opening | IPAD1_REJECTED |
| Parse-time packet buffering | IPAD1_REJECTED |

These move to SAFE only after an armv7 build and real iPad 1 runtime tests.


## Alpha15 Player-only compatibility decisions

| Feature | Status |
|---|---|
| Code-level suite scope gate | IPAD1_SAFE |
| 256 KB bounded PCM ring buffer | IPAD1_SAFE |
| Selected-audio-track-only decode policy | IPAD1_SAFE |
| Stereo/44.1 kHz conservative output profile | IPAD1_SAFE |
| AAC/MP3 real decode | IPAD1_TEST_REQUIRED |
| 480p H.264 software decode | IPAD1_TEST_REQUIRED |
| 720p software H.264 primary path | IPAD1_REJECTED |
| PDF/file-manager/download features in Player | IPAD1_REJECTED |


## Alpha16 MKV/H.264 policy

| Feature | Status |
|---|---|
| MKV demux | IPAD1_SAFE architecture / runtime test required |
| H.264 360p software playback | IPAD1_TEST_REQUIRED |
| H.264 480p software playback | IPAD1_TEST_REQUIRED |
| H.264 720p software primary path | IPAD1_REJECTED |
| H.264 720p verified legacy hardware/hybrid | IPAD1_TEST_REQUIRED |
| Above-720p software playback | IPAD1_REJECTED |

MKV/H.264 playback is explicitly within iPad1Player scope.


## Alpha17 audio runtime

| Feature | Status |
|---|---|
| AudioQueue 3x16 KB output buffers | IPAD1_TEST_REQUIRED |
| 256 KB PCM ring buffer | IPAD1_SAFE |
| AAC decoder source | IPAD1_TEST_REQUIRED |
| MP3 decoder source | IPAD1_TEST_REQUIRED |
| Packed S16 PCM path | IPAD1_TEST_REQUIRED |
| Non-S16 conversion via swresample | NOT ENABLED |
| AC3/E-AC3 decode | NOT ENABLED |

All alpha17 work is within iPad1Player scope.


## Alpha18 audio loop

| Feature | Status |
|---|---|
| Selected-stream av_read_frame loop | IPAD1_TEST_REQUIRED |
| Single demux thread | IPAD1_SAFE architecture |
| 64 KB decode scratch buffer | IPAD1_SAFE |
| PCM backpressure at 75% | IPAD1_SAFE |
| Audio clock from accepted PCM bytes | IPAD1_TEST_REQUIRED |
| Continuous AAC/MP3 playback | IPAD1_TEST_REQUIRED |
| Video decode in this phase | NOT ENABLED |

All Alpha18 changes remain inside iPad1Player responsibility.
