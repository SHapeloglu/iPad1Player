# Alpha10 — iPad 1 Hardening Pass

This release intentionally adds no heavy media feature.

## Goals

- reduce memory pressure
- make performance defaults conservative
- improve behavior under iOS memory warnings
- keep all experimental features behind test gates

## Memory budgets

Initial low-memory profile:
- compressed video packets: 3 MB maximum
- compressed audio packets: 768 KB maximum
- metadata working target: 384 KB
- decoded video frames: maximum target 2
- subtitle soft limit: 5000 cues

On memory warning:
- video compressed queue shrinks toward 1 MB
- audio compressed queue shrinks toward 256 KB
- nonessential subtitle sidecar list is released

## Safe playback-rate profile

Default exposed rates:
- 0.5x
- 0.75x
- 1.0x
- 1.25x
- 1.5x

2.0x remains experimental and is not part of the normal iPad 1 cycle until a real-device test passes.

## Parse safety

Alpha9 parse-only policy is tightened:
- metadata target: 384 KB
- track cap: 24
- chapter cap: 128

## Rejected defaults

- 720p software H.264 as primary path
- HEVC
- AV1
- VP9
- 4K
- HDR
- modern 10-bit pipelines

## Rule

Sector parity never overrides iPad 1 stability.
