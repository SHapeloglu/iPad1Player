# Codec / Konteyner Matrisi

Açıklama:
- READY = bugün yapılmış
- BACKEND = mimari hazır; FFmpeg çalışma zamanı gerekli
- P2 = MKV çekirdeği kararlı olduktan sonra planlanıyor
- OUT = iPad 1 için bilinçli olarak kapsam dışı

| Tür | Format | Durum |
|---|---|---|
| Konteyner | MP4 | READY |
| Konteyner | MOV | READY |
| Konteyner | M4V | READY |
| Konteyner | MKV | BACKEND |
| Konteyner | AVI | BACKEND / P2 |
| Video | H.264 / AVC | Yerleşik konteynerlerde READY; MKV/AVI'de BACKEND |
| Video | MPEG-4 Part 2 / Xvid | P2 |
| Ses | AAC | Yerleşik konteynerlerde READY; MKV'de BACKEND |
| Ses | MP3 | MKV'de BACKEND |
| Ses | AC3 | P2 |
| Ses | E-AC3 | P2 |
| Altyazı | harici SRT | READY |
| Altyazı | gömülü SRT | BACKEND |
| Altyazı | ASS / SSA | BACKEND |
| Video | HEVC / H.265 | OUT |
| Video | AV1 | OUT |
| Video | VP9 | OUT |
| Video | 4K/HDR/güncel 10 bit | OUT |
