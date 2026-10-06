# Alpha6 sektörle hizalama eklemeleri

## Bölümler
Artık hafif bir `IP1Chapter` modeli var. FFmpeg ile çıkarma, altyapı bağlanana kadar bilinçli olarak ertelendi.

Beklenen bölüm alanları:
- başlangıç zamanı
- başlık

## Uyku zamanlayıcısı
Player API'si dakika tabanlı uyku zamanlayıcısını destekler. Önerilen arayüz ön ayarları:
- Kapalı
- 15 dk
- 30 dk
- 45 dk
- 60 dk
- Medya sonunda (gelecekte altyapıya duyarlı seçenek)

## Oynatma hızı
Hedef ön ayarlar:
- 0.5x
- 0.75x
- 1.0x
- 1.25x
- 1.5x
- 2.0x

iPad 1'de daha yüksek hızlara bilinçli olarak öncelik verilmez.

## Ayrıntılı medya bilgisi
`IP1MediaInfo` şunları tutar:
- konteyner
- video codec
- ses codec
- boyutlar
- fps
- bit hızı
- ses örnekleme hızı
- kanallar
- süre

Yerleşik altyapı iOS 5'in açtığı kadarını doldurabilir. FFmpeg altyapısı bağlandığında tamamını dolduracak.

## Hâlâ altyapıya bağlı olanlar
- MKV/AVI'den bölüm çıkarma
- gömülü altyazıları listeleme
- birden fazla ses izini listeleme
- ses gecikmesini uygulama
- FFmpeg'den codec/fps/bit hızı çıkarma
