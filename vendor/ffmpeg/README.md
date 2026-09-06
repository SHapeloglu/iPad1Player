# Legacy FFmpeg vendor directory

No FFmpeg binaries are bundled in this source package.

Expected layout when enabling `IP1_FFMPEG_BACKEND`:

```
vendor/ffmpeg/
  include/
    libavformat/
    libavcodec/
    libavutil/
  lib/
    libavformat.a
    libavcodec.a
    libavutil.a
```

Requirements:
- armv7 static libraries
- compatible with the legacy iOS 5.1 deployment target / iPhoneOS 6.1 SDK toolchain
- no simulator-only slices
- parse-only alpha14 does not require swresample

Do not enable `IP1_LEGACY_H264_HW` here.
