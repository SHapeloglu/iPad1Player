# CLAUDE.md — iPad1Player

**iPad 1 / iOS 5.1.1 / armv7 / ~256 MB RAM** için medya oynatıcı; Objective-C/UIKit, **non-ARC**, Theos, eski iPhoneOS 6.1 SDK. Demux, ses/video çözme ve çıkış, A/V senkronizasyonu, ileri sarma/devam, oynatma kontrolleri, altyazılar, iz seçimi, bölümler, medya bilgisi ve oynatma tanılamasından sorumludur. Paket `com.olap.ipad1player` **0.1-alpha18** (`control`).

- GitHub: https://github.com/SHapeloglu/iPad1Player
- **Belirleyici devir belgesi: `PROJECT_CONTEXT.md`.** Ardından `ARCHITECTURE.md`, `TASK.md`, `SESSION.md`, `SUITE_HANDOFF.md`, `docs/` (alpha başına notlar ALPHA6…ALPHA18, `CODEC_MATRIX.md`, `PLAYBACK_ENGINE.md`, `MKV_BACKEND.md`, `IPAD1_COMPATIBILITY.md`, `RESPONSIBILITY.md`).

## Güncel durum (gerçek iPad 1'de doğrulandı)

MKV → FFmpeg demux (tek `av_read_frame` iş parçacığı) → AAC çözme → kalıcı swresample → PCM halka → AudioQueue; ve H.264 Main 854×480 → sınırlı paket kuyruğu → ayrılmış çözme işçisi → YUV420P → OpenGL ES 2 YUV shader → CAEAGLLayer. Ses ve video, önceki mikro donmalar olmadan birlikte oynuyor.

**Hemen yapılacak sonraki adım (PROJECT_CONTEXT):** zaman damgasına duyarlı A/V senkronizasyonu — ana saat ses, video PTS, sınırlı zamanlama, kontrollü geç kare atma. Bu kararlı olmadan ilgisiz özelliklere başlama.

## Derleme

```bash
make clean && make package FINALPACKAGE=1     # ARCHS=armv7, TARGET=iphone:clang:6.1:5.1, -fno-objc-arc, -DIP1_FFMPEG_BACKEND
```

- FFmpeg altyapısı `vendor/ffmpeg/lib` altındaki **armv7 statik kütüphaneleri** bağlar (`libavformat.a`, `libavcodec.a`, `libavutil.a`, swresample). Git'te yalnızca başlık dosyaları + pkgconfig var; `.a` dosyaları yerelde bulunmalı (bkz. `vendor/ffmpeg/README.md`).
- Eski `ssh-rsa` seçenekleriyle SSH üzerinden kurulur; kardeş uygulamalar `ipad1player://open?path=<percent-encoded-local-path>` ile açar.

## Kurallar

- Uygulama ailesi sınırı: dosya gezinme/arşivler → iPad1Files; indirmeler → iPad1Downloader/FTPDownloader; PDF → iPad1PDFReader. Bu sorumlulukları oynatıcıya çekme.
- Codec politikası: 854×480'e kadar yazılımsal H.264, AAC, MP3, MKV, uyumluysa AVI, eski MediaPlayer ile yerleşik MP4/MOV/M4V. **Reddedilenler:** HEVC, AV1, VP9, 4K, HDR, 10 bit, yazılımsal 720p H.264, ağır ASS görüntüleme.
- Tam olarak bir demux okuyucusu; her kuyruk sınırlı; kare/paket kopyalarından kaçın; kalıcı SwrContext; görüntüleyici yalnızca en son kareyi tutar.
- Manuel retain/release; işçi döngülerinde `@autoreleasepool`; yalnızca iOS 5 API'leri.
- Bir özellik ancak gerçek cihazda oynatıldıktan sonra "çalışıyor" sayılır — derlenmesi yetmez. Sonuçları `SESSION.md` / `docs/ALPHA*.md`'ye yaz.
