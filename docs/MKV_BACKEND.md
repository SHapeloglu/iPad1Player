# MKV / FFmpeg Altyapı Planı — alpha4

## Hedef

iPad1Files, iPad1Downloader veya iPad1PDFReader'ın sorumluluklarını çoğaltmadan iPad1Player'ın ilk gerçek MKV altyapısını yapmak.

Hedef:
- iPad 1
- iOS 5.1.1
- armv7
- ~256 MB RAM
- non-ARC/MRC
- eski iPhoneOS 6.1 SDK

## Hat

MKV -> FFmpeg demux -> sınırlı paket kuyrukları -> video/ses çözücüler -> A/V saati -> görüntüleyici/ses çıkışı

### Video
Öncelik:
1. H.264 akışını algılama.
2. Eski donanım destekli yol yalnızca gerçek bir iPad 1'de doğrulandığında.
3. Yazılımsal çözmeye geri dönüş.
4. Sınırsız kuyruğa izin vermek yerine geç kalan kareleri atma.

### Ses
İlk codec'ler:
- AAC
- MP3

Ses mevcutsa tercih edilen ana saat olur.

### Senkronizasyon
- Ses aktifse ana saat sestir.
- Video karesi çok erken -> kısa bekleme.
- Video karesi çok geç -> atma.
- Altyazı saati sunum zamanı + kullanıcının altyazı kaydırmasını izler.
- Ses gecikmesi altyapı API'sinde temsil edilir ve FFmpeg sesi aktif olunca ses saati/çıkış yolunda uygulanır.

## Düşük bellek sınırları

Kuyruk uygulaması bilinçli olarak sınırlıdır.

Önerilen başlangıç bütçesi:
- sıkıştırılmış video paketleri: <= 4 MB
- sıkıştırılmış ses paketleri: <= 1 MB
- çözülmüş video kareleri: <= 3 kare
- çözülmüş ses: yalnızca kısa döner tampon

MKV dosyasının tamamını veya sınırsız altyazı/kare geçmişini asla önbelleğe alma.

## İz modeli

`IP1MediaTrack` şunları temsil eder:
- video
- ses
- altyazı

Altyapı sözleşmesi zaten şunları destekliyor:
- birden fazla ses izi
- birden fazla gömülü altyazı izi
- seçili ses/altyazı izi
- ses gecikmesi
- altyazı gecikmesi
- çözme modu

## Derleme bayrakları

Kaynak FFmpeg olmadan da derlenebilir kalır.

Adaptör kodunu yalnızca eski armv7 kütüphaneleri gerçekten bağlandığında aç:

```make
iPad1Player_CFLAGS += -DIP1_FFMPEG_BACKEND
```

Gerçek bir iPad 1 testi donanım yolunu doğrulamadan `IP1_LEGACY_H264_HW`'yi açma.

## Önemli uyumluluk kuralı

iOS 5.1.1'de güncel VideoToolbox API'lerinin var olduğunu varsayma. Donanım destekli H.264, hedef cihazda/SDK'da gerçekten bulunan API'lere dayanmalı ve cihaz üzerinde testle kanıtlanmalıdır.
