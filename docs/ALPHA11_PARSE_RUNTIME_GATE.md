# Alpha11 — iPad 1 Ayrıştırma Çalışma Zamanı Kapısı

Alpha11, sıkı iPad 1 sınırlarıyla ilk gerçek libavformat metadata ayrıştırmasını hazırlar.

## İzin verilenler

- libavformat ile MKV/AVI açma
- akışları listeleme
- codec/konteyner metadata'sı
- ses örnekleme hızı/kanalları
- altyazı izi metadata'sı
- bölüm metadata'sı
- ayrıştırma tanılaması

## Hâlâ izin verilmeyenler

- video karesi çözme
- ses çözme
- PCM çıkışı
- ayrıştırma sırasında paket ön tamponlama
- arka plan medya dizinleme
- ayrıştırmadan sonra kalıcı FFmpeg bağlamları

## Savunmacı sınırlar

- metadata hedefi: 384 KB
- en fazla iz: 24
- en fazla bölüm: 128
- ayrıştırma süresi hedefi: <= 8 saniye
- medya süresi makullük sınırı: 8 saat
- akış başlıkları 80 karaktere kısaltılır
- dil metadata'sı normalleştirilir ve sınırlandırılır

## Ayrıştır-ve-kapat kuralı

`parseAndCloseMediaAtPath`, metadata çıkarıldıktan hemen sonra tüm FFmpeg bağlam durumunu serbest bırakmalıdır.

Bu iPad 1'de zorunludur.

## Cihaz testi

FFmpeg ayrıştırmayı SAFE olarak işaretlemeden önce:
1. armv7 derlemesi geçer.
2. iOS 5.1.1'de açılış geçer.
3. MKV çökmeden ayrıştırılır.
4. bellek baskısı testi geçer.
5. tekrarlı ayrıştır/kapat döngüleri sızıntı yapmaz.
6. ayrıştırma gecikmesi kabul edilebilir.
