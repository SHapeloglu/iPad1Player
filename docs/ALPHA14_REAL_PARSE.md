# Alpha14 — Gerçek libavformat Ayrıştırma Yolu

Alpha14, `IP1_FFMPEG_BACKEND` açıkken FFmpeg ayrıştırma taslağını gerçek bir libavformat ayrıştırma uygulamasıyla değiştirir.

## Gerçek API yolu

- `avformat_open_input`
- `avformat_find_stream_info`
- akışları listeleme
- `avcodec_get_name`
- akış dil/başlık metadata'sı
- konteyner adı
- süre / bit hızı
- video genişlik / yükseklik / FPS
- ses örnekleme hızı / kanallar
- bölüm çıkarma
- `avformat_close_input`

## Eski FFmpeg uyumluluğu

`IP1FFmpegCompat.h`, eski `AVStream.codec` ile yeni `AVStream.codecpar` arasındaki farkı gizler.

Bu sayede proje, oynatıcı kodunu yalnızca güncel FFmpeg API'sine bağlamadan iOS 5.1.1'e uygun eski bir FFmpeg derlemesini test edebilir.

## Korunan iPad 1 kuralları

Yalnız ayrıştırma modu:
- hiçbir çözücü açmaz
- hiçbir çözücü iş parçacığı başlatmaz
- hiçbir paketi kuyruğa almaz
- hiçbir çözülmüş kare ayırmaz
- dönmeden önce `AVFormatContext`'i kapatır

Mevcut sınırlar geçerliliğini korur:
- en fazla 24 iz
- en fazla 128 bölüm
- metadata doğrulaması
- bozuk dosya ön kontrolü
- ayrıştırma tanılaması
- tekrarlı ayrıştır/kapat test düzeneği

## Önemli

Kaynak kod artık gerçek bir libavformat ayrıştırma yolu içeriyor, ancak ZIP paketi bilinçli olarak FFmpeg statik kütüphanelerini içermiyor.

Bu yüzden:
- `IP1_FFMPEG_BACKEND` olmadan derleme, yerleşik oynatıcı yolları için çalışır durumda kalır
- gerçek MKV metadata ayrıştırması ancak uyumlu armv7 statik FFmpeg kütüphaneleri sağlanıp derleme bayrağı açıldığında devreye girer

alpha14'te video/ses çözme açılmadı.
