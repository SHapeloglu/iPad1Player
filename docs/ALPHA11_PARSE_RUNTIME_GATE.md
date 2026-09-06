# Alpha11 — iPad 1 Parse Runtime Gate

Alpha11 prepares the first real libavformat metadata parse with strict iPad 1 limits.

## Allowed

- MKV/AVI open through libavformat
- stream enumeration
- codec/container metadata
- audio sample rate/channels
- subtitle track metadata
- chapter metadata
- parse diagnostics

## Still not allowed

- video frame decode
- audio decode
- PCM output
- packet prebuffering during parse
- background media indexing
- persistent FFmpeg contexts after parse

## Defensive limits

- metadata target: 384 KB
- max tracks: 24
- max chapters: 128
- parse time target: <= 8 seconds
- media duration sanity cap: 8 hours
- stream titles are truncated to 80 characters
- language metadata is normalized and bounded

## Parse-and-close rule

`parseAndCloseMediaAtPath` must release all FFmpeg context state immediately after metadata extraction.

This is mandatory on iPad 1.

## Device test

Before marking FFmpeg parse as SAFE:
1. armv7 build passes.
2. iOS 5.1.1 launch passes.
3. MKV parses without crash.
4. memory pressure test passes.
5. repeated parse/close cycles do not leak.
6. parse latency is acceptable.
