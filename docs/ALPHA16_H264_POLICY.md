# Alpha16 — iPad 1 MKV/H.264 Oynatma Politikası

MKV + H.264 oynatma açıkça iPad1Player'ın sorumluluğudur.

Alpha16 henüz bir çözücü açmaz; gelecekteki FFmpeg çözmenin uyması gereken çalışma zamanı karar politikasını tanımlar.

## Güvenli hedef

Yazılımsal H.264 test hedefi:
- 360p sınıfı
- 480p sınıfı
- yaklaşık 854x480'e kadar

Durum:
- gerçek cihazda oynatma geçene kadar TEST_REQUIRED
- amaçlanan birincil yazılımsal yol

## 720p

720p sınıfı H.264:
- yazılımsal çözme birincil yol DEĞİL
- yalnızca doğrulanmış eski donanım/hibrit çözme yoluyla izinli
- TEST_REQUIRED olarak kalıyor
- `IP1_LEGACY_H264_HW`, gerçek bir iPad 1 testi olmadan açılmamalı

## 720p üstü

Normal iPad 1 oynatması için reddedildi.

## Neden

Amaç MKV/H.264'ü reddetmek değil. Amaç, çözme yöntemini A4 işlemci ve ~256 MB RAM sınırlarına göre seçmek.

Konteyner ayrıştırma ve H.264 oynatma ayrı konulardır:
- MKV demux yeterince hafiftir
- H.264 çözme maliyeti büyük ölçüde çözünürlüğe/profile/bit hızına bağlıdır

## Player kapsamı

iPad1Player'a ait:
- MKV demux
- H.264 çözme
- görüntüleyici
- A/V senkronizasyonu
- kare atma
- ses çözme/çıkışı
- altyazı/ses izi seçimi

Ait olmayan:
- dosya gezinme/yönetimi -> iPad1Files
- PDF/belge okuma -> iPad1PDFReader
- indirmeler -> iPad1Downloader
