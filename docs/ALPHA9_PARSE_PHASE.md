# Alpha9 — FFmpeg Integration Phase 1 (Parse-Only)

## Scope

This phase is intentionally limited to low-memory metadata parsing.

Allowed:
- open MKV/AVI container with libavformat
- stream discovery
- video/audio/subtitle track enumeration
- chapter extraction
- media info extraction

Not allowed in alpha9:
- frame decode
- audio decode
- packet prebuffering
- video renderer
- PCM output
- hardware decode claims

## iPad 1 constraints

Target:
- iPad 1 / A4
- iOS 5.1.1
- armv7
- ~256 MB RAM
- MRC/non-ARC

Parse-only rules:
- close FFmpeg context after metadata read
- no packet queues during parse-only operation
- no frame allocations
- no entire-file scanning beyond what libavformat requires
- no background indexing service
- no persistent media library cache in Player

## Limits

Initial safety caps:
- metadata working budget: <= 512 KB target
- tracks: <= 32
- chapters: <= 256

These are defensive limits for legacy hardware and may be adjusted after real-device tests.

## Required outputs

`IP1FFmpegParseResult`
- tracks
- chapters
- mediaInfo

## Test gate

A feature moves from TEST_REQUIRED to SAFE only after:
- armv7 build succeeds
- iOS 5.1.1 runtime test succeeds
- no crash under memory pressure
- acceptable open/parse latency
