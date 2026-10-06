# Eski FFmpeg sağlayıcı (vendor) klasörü

Bu kaynak paketinde FFmpeg ikili dosyaları yoktur.

`IP1_FFMPEG_BACKEND` açılırken beklenen düzen:

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

Gereksinimler:
- armv7 statik kütüphaneler
- eski iOS 5.1 dağıtım hedefi / iPhoneOS 6.1 SDK toolchain'i ile uyumlu
- yalnız simülatöre ait dilim (slice) yok
- yalnız ayrıştıran alpha14 swresample gerektirmez

`IP1_LEGACY_H264_HW`'yi burada açma.
