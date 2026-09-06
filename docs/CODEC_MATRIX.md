# Codec / Container Matrix

Legend:
- READY = implemented today
- BACKEND = architecture exists; FFmpeg runtime required
- P2 = planned after MKV core is stable
- OUT = intentionally out of scope for iPad 1

| Type | Format | Status |
|---|---|---|
| Container | MP4 | READY |
| Container | MOV | READY |
| Container | M4V | READY |
| Container | MKV | BACKEND |
| Container | AVI | BACKEND / P2 |
| Video | H.264 / AVC | READY in native containers; BACKEND in MKV/AVI |
| Video | MPEG-4 Part 2 / Xvid | P2 |
| Audio | AAC | READY in native containers; BACKEND in MKV |
| Audio | MP3 | BACKEND in MKV |
| Audio | AC3 | P2 |
| Audio | E-AC3 | P2 |
| Subtitle | external SRT | READY |
| Subtitle | embedded SRT | BACKEND |
| Subtitle | ASS / SSA | BACKEND |
| Video | HEVC / H.265 | OUT |
| Video | AV1 | OUT |
| Video | VP9 | OUT |
| Video | 4K/HDR/modern 10-bit | OUT |
