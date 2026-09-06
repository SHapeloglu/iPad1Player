# Alpha13 — iPad 1 Robustness Pass

Alpha13 adds only low-risk defensive features suitable for iPad 1.

## Added

### Media preflight
Before FFmpeg/native parsing:
- path must exist
- file must not be empty
- extension must be in the supported parse set
- obviously unreasonable file size is rejected

The 32 GiB file-size cap is a defensive sanity check only; the file is never loaded into RAM.

### Parse result sanity checks
Reject invalid metadata such as:
- dimensions above 4096x4096
- FPS above 120
- audio sample rate above 192 kHz
- more than 16 audio channels
- negative values

These are corruption-defense limits, not playback capability claims.

### Repeated parse/close harness
`IP1ParseStressTester`:
- defaults to 10 iterations
- hard caps at 25 iterations
- uses a per-iteration autorelease pool
- stops early after repeated failures
- records elapsed time and failures

This is intentionally lightweight for iPad 1.

## Leak testing rule

The harness detects functional instability only. Actual memory-leak validation still requires observing process memory on a real device while repeated parse/close cycles run.

## Still disabled

- H.264 decode
- AAC/MP3 decode
- renderer
- PCM output
- hardware decode
- background indexing
