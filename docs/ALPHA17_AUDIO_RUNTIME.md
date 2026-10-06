# Alpha17 — iPad 1 Ses Çalışma Zamanı

Alpha17 yalnızca Player'a ait ses çalışma zamanı parçalarını uygular.

## Eklenenler

### AudioQueue çıkışı
- iOS 5 uyumlu AudioQueue API'si
- 16 KB çıkış tamponları
- 3 kuyruk tamponu (~48 KB AudioQueue yükü)
- sınırlı 256 KB PCM halka tampon
- 16 bit işaretli stereo temel değer
- temkinli varsayılan 44.1 kHz

### FFmpeg AAC/MP3 çözücü kaynağı
`IP1_FFMPEG_BACKEND` bağlandığında:
- AAC çözücü arama
- MP3 çözücü arama
- eski/yeni FFmpeg çözme API dalları
- paketlenmiş S16 PCM çıkış yolu

S16 dışı FFmpeg örnek formatları, `swresample` eklenip iPad 1'de test edilene kadar bilinçli olarak reddedilir.

## Kapsam filtresi

Bu sürümdeki tüm işler iPad1Player'a aittir:
- ses çözme
- PCM tamponlama
- ses cihazı çıkışı
- ses saati temeli

Şunlarda değişiklik gerekmez:
- iPad1Files
- iPad1PDFReader
- iPad1Downloader

## Önemli sınırlamalar

Bu kaynak paketi hâlâ FFmpeg armv7 statik kütüphanelerini içermiyor.
Bu yüzden çözücü kaynağı ancak doğrulanmış altyapı bağlandığında devreye girer.

Demux döngüsü henüz çözülen AAC/MP3 paketlerini sürekli besleyecek şekilde bağlanmadı.
Alpha17, bir sonraki entegrasyon için gereken gerçek çözücü/çıkış bileşenlerini sağlıyor.
