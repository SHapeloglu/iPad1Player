# Alpha15 — Uygulama Ailesi Kapsam Denetimi + iPad 1 Ses Temeli

## Zorunlu uygulama ailesi filtresi

iPad1Player yalnızca medya oynatma sorumluluklarına sahiptir.

### iPad1Player
- demux
- ses/video çözme
- ses çıkışı
- görüntüleyici
- A/V senkronizasyonu
- ileri sarma/devam
- oynatma kontrolleri
- altyazılar
- ses/altyazı izi seçimi
- bölümler/medya bilgisi
- oynatma tanılaması

### iPad1Files
- dizin gezinme
- dosya arama/sıralama
- yeniden adlandır/kopyala/taşı/sil
- klasör oluşturma
- arşiv/ZIP/RAR
- genel dosya bilgisi ve favoriler

### iPad1PDFReader
- PDF görüntüleme
- PDF sayfa gezinme
- PDF metin/okuma modu
- belge okuma
- PDF yer imleri

### iPad1Downloader
- HTTP/HTTPS/FTP indirme
- indirme kuyruğu
- devam/yeniden deneme
- kalıcı uzak dosya transferi

Player, rakipler bunları bir arada sunuyor diye asla bu sorumlulukları üstlenmemelidir.

## Alpha15'te yalnız Player'a ait işler

### Düşük bellekli PCM temeli
- sabit 256 KB PCM halka tampon
- sınırsız çözülmüş ses kuyruğu yok
- durdurmada/bellek uyarısında temizleme
- yalnızca seçilen ses izi politikası

### Güvenli ses varsayılanları
- tercihen stereo çıkış
- tercihen 44.1 kHz temel değer
- AAC/MP3 1. seviye
- AC3/E-AC3 cihaz testine kadar varsayılan olarak kapalı

### Video politikası
- 480p yazılımsal H.264 test edilebilir
- 720p yazılımsal H.264 birincil yol değil
- donanım/hibrit H.264 test kapısının arkasında kalıyor

## Önemli
Alpha15 henüz gerçek AAC/MP3 çözme veya cihazda PCM çıkışı iddia etmiyor.
Bir sonraki adım için gereken, Player'a ait düşük bellekli çalışma zamanı sınırını sağlıyor.
