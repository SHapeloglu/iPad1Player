# Alpha12 — iPad 1 FFmpeg Pre-Integration Gate

Alpha12 is the final low-risk preparation before linking real FFmpeg libraries.

## Added

- build-time FFmpeg capability report
- parse result validation
- explicit fallback policy
- stricter parse error handling
- real-device test checklist

## Parse validation

A parse result is rejected when:
- result is nil
- track/chapter caps are exceeded
- duration sanity cap is exceeded
- diagnostics report out-of-limit parsing

## Fallback behavior

Native containers:
- MP4/MOV/M4V -> native metadata path

FFmpeg containers:
- MKV/AVI -> require FFmpeg parse backend
- no fake fallback claiming support

## Real iPad 1 checklist

Before enabling `IP1_FFMPEG_BACKEND` in release builds:

1. Build succeeds for armv7.
2. Launch succeeds on iOS 5.1.1.
3. Repeated MKV parse/open/close cycles do not leak.
4. Parse latency is acceptable.
5. Memory warning during/after parse does not crash.
6. 24-track and 128-chapter caps behave correctly.
7. Corrupt MKV returns a controlled error.
8. Very large MKV metadata does not trigger unbounded allocation.
9. FFmpeg context is closed after parse-only operation.
10. No decoder thread starts in parse-only mode.

## Still not enabled

- video decode
- audio decode
- PCM output
- renderer
- hardware H.264
