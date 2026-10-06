# Alpha9 — FFmpeg Entegrasyonu 1. Aşama (Yalnızca Ayrıştırma)

## Kapsam

Bu aşama bilinçli olarak düşük bellekli metadata ayrıştırmayla sınırlıdır.

İzin verilenler:
- libavformat ile MKV/AVI konteynerini açma
- akışları bulma
- video/ses/altyazı izlerini listeleme
- bölüm çıkarma
- medya bilgisi çıkarma

alpha9'da izin verilmeyenler:
- kare çözme
- ses çözme
- paket ön tamponlama
- video görüntüleyici
- PCM çıkışı
- donanım çözme iddiaları

## iPad 1 kısıtları

Hedef:
- iPad 1 / A4
- iOS 5.1.1
- armv7
- ~256 MB RAM
- MRC/non-ARC

Yalnızca ayrıştırma kuralları:
- metadata okunduktan sonra FFmpeg bağlamını kapat
- yalnız ayrıştırma sırasında paket kuyruğu yok
- kare ayırma yok
- libavformat'ın gerektirdiğinin ötesinde tüm dosyayı tarama yok
- arka plan dizinleme servisi yok
- Player'da kalıcı medya kütüphanesi önbelleği yok

## Sınırlar

İlk güvenlik sınırları:
- metadata çalışma bütçesi: hedef <= 512 KB
- izler: <= 32
- bölümler: <= 256

Bunlar eski donanım için savunmacı sınırlardır ve gerçek cihaz testlerinden sonra ayarlanabilir.

## Gerekli çıktılar

`IP1FFmpegParseResult`
- izler
- bölümler
- medya bilgisi

## Test kapısı

Bir özellik TEST_REQUIRED'dan SAFE'e ancak şunlardan sonra geçer:
- armv7 derlemesi başarılı
- iOS 5.1.1 çalışma zamanı testi başarılı
- bellek baskısında çökme yok
- kabul edilebilir açma/ayrıştırma gecikmesi
