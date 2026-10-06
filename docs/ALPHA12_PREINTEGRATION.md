# Alpha12 — iPad 1 FFmpeg Entegrasyon Öncesi Kapı

Alpha12, gerçek FFmpeg kütüphanelerini bağlamadan önceki son düşük riskli hazırlıktır.

## Eklenenler

- derleme zamanı FFmpeg yetenek raporu
- ayrıştırma sonucu doğrulaması
- açık geri dönüş politikası
- daha sıkı ayrıştırma hata işleme
- gerçek cihaz test kontrol listesi

## Ayrıştırma doğrulaması

Bir ayrıştırma sonucu şu durumlarda reddedilir:
- sonuç nil
- iz/bölüm sınırları aşıldı
- süre makullük sınırı aşıldı
- tanılama sınır dışı ayrıştırma bildiriyor

## Geri dönüş davranışı

Yerleşik konteynerler:
- MP4/MOV/M4V -> yerleşik metadata yolu

FFmpeg konteynerleri:
- MKV/AVI -> FFmpeg ayrıştırma altyapısı gerekir
- destek varmış gibi gösteren sahte geri dönüş yok

## Gerçek iPad 1 kontrol listesi

Sürüm derlemelerinde `IP1_FFMPEG_BACKEND`'i açmadan önce:

1. armv7 için derleme başarılı.
2. iOS 5.1.1'de açılış başarılı.
3. Tekrarlı MKV ayrıştır/aç/kapat döngüleri sızıntı yapmıyor.
4. Ayrıştırma gecikmesi kabul edilebilir.
5. Ayrıştırma sırasında/sonrasında bellek uyarısı çökmeye yol açmıyor.
6. 24 iz ve 128 bölüm sınırları doğru çalışıyor.
7. Bozuk MKV kontrollü bir hata döndürüyor.
8. Çok büyük MKV metadata'sı sınırsız bellek ayırmaya yol açmıyor.
9. Yalnız ayrıştırma işleminden sonra FFmpeg bağlamı kapatılıyor.
10. Yalnız ayrıştırma modunda hiçbir çözücü iş parçacığı başlamıyor.

## Hâlâ açılmayanlar

- video çözme
- ses çözme
- PCM çıkışı
- görüntüleyici
- donanım H.264
