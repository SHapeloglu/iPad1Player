# Rakiplerden Alınan Player Özellikleri Günlüğü

Bu dosya, uygulama ailesi sorumluluk filtresinden geçtikten sonra iPad1Player için kabul edilen, rakiplerden esinlenen özellikleri kaydeder.

## alpha4'e kadar yapılanlar

- Harici SRT otomatik eşleştirme ve dil ekli yan dosyalar.
- Altyazı aç/kapat.
- Altyazı gecikmesi.
- Altyazı yazı boyutu ve dikey konumu.
- Elle altyazı kodlaması seçimi.
- Kaldığı yerden devam.
- Hareketle +/-10 saniye sarma.
- Ayrıntılı en-boy oranı ön ayarları.
- Oynatma hızı.
- A-B tekrar.
- Parlaklık hareketi.
- Ses düzeyi hareketi.
- Oynatma kontrol kilidi.
- Temel medya bilgisi.

## MKV altyapısı gerektirenler

- MKV demux/oynatma.
- Birden fazla ses izi.
- Gömülü altyazı izleri.
- ASS/SSA desteği.
- Ses gecikmesi.
- Donanım destekli H.264 yolu.
- Ayrıntılı codec/fps/bit hızı bilgisi.

## Player'dan açıkça reddedilenler

- Dosya gezgini, yeniden adlandır, taşı, kopyala, sil, klasörler, arşivler -> iPad1Files.
- İndirme kuyruğu / HTTP-FTP indirme yönetimi -> iPad1Downloader.
- PDF görüntüleme/okuma/yer imi -> iPad1PDFReader.


## Alpha4 altyapı çalışması

Gerçek mimari/kod sınırları olarak yapılanlar:
- sınırlı paket kuyruğu
- medya izi modeli
- çoklu ses seçimi sözleşmesi
- gömülü altyazı seçimi sözleşmesi
- ses gecikmesi sözleşmesi
- altyazı gecikmesi sözleşmesi
- çözme modu sözleşmesi
- medya bilgisi altyapı sözleşmesi
- isteğe bağlı FFmpeg derleme kancaları

Hâlâ gerçek sağlayıcı/çalışma zamanı uygulaması gerektirenler:
- FFmpeg demux/çözme
- MKV'den AAC/MP3 çözme
- gömülü altyazı çıkarma/görüntüleme
- doğrulanmış eski donanım H.264 yolu
