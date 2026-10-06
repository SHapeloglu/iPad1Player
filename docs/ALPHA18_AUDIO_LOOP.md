# Alpha18 — iPad 1 Uçtan Uca Ses Döngüsü

Alpha18, Player'a ait ses çalışma zamanı yolunu birbirine bağlar:

```
MKV/AVI
  -> av_read_frame
  -> selected AAC/MP3 stream only
  -> IP1FFmpegAudioDecoder
  -> packed S16 PCM
  -> bounded 256 KB PCM ring
  -> AudioQueue
  -> audio master clock
```

## iPad 1 kısıtları

- yalnızca tek demux iş parçacığı
- yalnızca seçilen ses akışı
- bu yalnız-ses çalışma zamanı aşamasında tüm video/altyazı paketleri atlanır
- 64 KB çözme karalama tamponu
- PCM halkası %75 doluluğu aşınca çözücü bekler
- 3 x 16 KB AudioQueue çıkış tamponu
- sınırsız paket/PCM kuyruğu yok
- iş parçacığı başına autorelease pool
- FFmpeg bağlamı iş parçacığı çıkışında kapanır

## Saat

Ses çalışma zamanı, kabul edilen S16 PCM miktarından saat zamanını günceller:

`seconds = bytes / (sampleRate * channels * 2)`

Bu, video senkronizasyonu için gelecekteki ana saat olacak.

## Kapsam incelemesi

Alpha18'deki hiçbir özellik şunlara ait değildir:
- iPad1Files
- iPad1PDFReader
- iPad1Downloader

Tüm değişiklikler iPad1Player'ın doğrudan medya oynatma sorumluluklarıdır.

## Sınırlamalar

- FFmpeg armv7 statik kütüphaneleri hâlâ harici.
- Yalnızca paketlenmiş S16 çözücü çıkışı kabul ediliyor.
- FLTP/S16P çıkışı veren AAC/MP3 çözücüler hâlâ test edilmiş bir swresample aşaması gerektiriyor.
- Bu sürüm H.264 video çözmüyor.
- İleri sarmanın ses oturumuna entegrasyonu sıradaki çalışma zamanı adımı.
