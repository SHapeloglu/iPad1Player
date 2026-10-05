# CLAUDE.md — iPad1Player

Media player for **iPad 1 / iOS 5.1.1 / armv7 / ~256 MB RAM**, Objective-C/UIKit, **non-ARC**, Theos, legacy iPhoneOS 6.1 SDK. Owns demux, audio/video decode and output, A/V sync, seek/resume, playback controls, subtitles, track selection, chapters, media info and playback diagnostics. Package `com.olap.ipad1player` **0.1-alpha18** (`control`).

- GitHub: https://github.com/SHapeloglu/iPad1Player
- **Authoritative handoff: `PROJECT_CONTEXT.md`.** Then `ARCHITECTURE.md`, `TASK.md`, `SESSION.md`, `SUITE_HANDOFF.md`, `docs/` (per-alpha notes ALPHA6…ALPHA18, `CODEC_MATRIX.md`, `PLAYBACK_ENGINE.md`, `MKV_BACKEND.md`, `IPAD1_COMPATIBILITY.md`, `RESPONSIBILITY.md`).

## Current state (verified on the real iPad 1)

MKV → FFmpeg demux (single `av_read_frame` thread) → AAC decode → persistent swresample → PCM ring → AudioQueue, and H.264 Main 854×480 → bounded packet queue → dedicated decode worker → YUV420P → OpenGL ES 2 YUV shader → CAEAGLLayer. Simultaneous audio+video plays without the earlier micro-freezes.

**Immediate next action (PROJECT_CONTEXT):** timestamp-aware A/V sync — audio as master clock, video PTS, bounded scheduling, controlled late-frame dropping. Don't start unrelated features before this is stable.

## Build

```bash
make clean && make package FINALPACKAGE=1     # ARCHS=armv7, TARGET=iphone:clang:6.1:5.1, -fno-objc-arc, -DIP1_FFMPEG_BACKEND
```

- The FFmpeg backend links **armv7 static libs** from `vendor/ffmpeg/lib` (`libavformat.a`, `libavcodec.a`, `libavutil.a`, swresample). Only headers + pkgconfig are in git; the `.a` files must exist locally (see `vendor/ffmpeg/README.md`).
- Install over SSH with legacy `ssh-rsa` options; opened by siblings via `ipad1player://open?path=<percent-encoded-local-path>`.

## Rules

- Suite boundary: file browsing/archives → iPad1Files; downloads → iPad1Downloader/FTPDownloader; PDF → iPad1PDFReader. Don't pull those responsibilities into the player.
- Codec policy: H.264 software ≤ 854×480, AAC, MP3, MKV, AVI where compatible, native MP4/MOV/M4V via legacy MediaPlayer. **Rejected:** HEVC, AV1, VP9, 4K, HDR, 10-bit, H.264 720p software, heavy ASS rendering.
- Exactly one demux reader; every queue bounded; avoid frame/packet copies; persistent SwrContext; renderer keeps only the latest frame.
- Manual retain/release; `@autoreleasepool` in worker loops; iOS 5 APIs only.
- A feature is "working" only after real-device playback — compiling is not enough. Record results in `SESSION.md` / `docs/ALPHA*.md`.
