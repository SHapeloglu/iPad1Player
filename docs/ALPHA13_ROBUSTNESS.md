# Alpha13 — iPad 1 Sağlamlık Aşaması

Alpha13 yalnızca iPad 1'e uygun, düşük riskli savunmacı özellikler ekler.

## Eklenenler

### Medya ön kontrolü
FFmpeg/yerleşik ayrıştırmadan önce:
- yol mevcut olmalı
- dosya boş olmamalı
- uzantı desteklenen ayrıştırma kümesinde olmalı
- açıkça makul olmayan dosya boyutu reddedilir

32 GiB dosya boyutu sınırı yalnızca savunmacı bir makullük kontrolüdür; dosya asla RAM'e yüklenmez.

### Ayrıştırma sonucu makullük kontrolleri
Şu gibi geçersiz metadata reddedilir:
- 4096x4096'dan büyük boyutlar
- 120'nin üzerinde FPS
- 192 kHz'in üzerinde ses örnekleme hızı
- 16'dan fazla ses kanalı
- negatif değerler

Bunlar bozulmaya karşı savunma sınırlarıdır, oynatma yeteneği iddiası değildir.

### Tekrarlı ayrıştır/kapat düzeneği
`IP1ParseStressTester`:
- varsayılan 10 tekrar
- kesin üst sınır 25 tekrar
- her tekrarda ayrı autorelease pool
- tekrarlanan hatalardan sonra erken durur
- geçen süreyi ve hataları kaydeder

Bu düzenek iPad 1 için bilinçli olarak hafiftir.

## Sızıntı testi kuralı

Düzenek yalnızca işlevsel kararsızlığı tespit eder. Gerçek bellek sızıntısı doğrulaması, tekrarlı ayrıştır/kapat döngüleri çalışırken gerçek cihazda süreç belleğini izlemeyi gerektirir.

## Hâlâ kapalı olanlar

- H.264 çözme
- AAC/MP3 çözme
- görüntüleyici
- PCM çıkışı
- donanım çözme
- arka plan dizinleme
