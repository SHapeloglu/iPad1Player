# iPad1Player — Proje Bağlamı

> Bu doküman geliştirmeye devam etmek için belirleyici devir belgesidir.

## Proje

iPad1Player özellikle şunlar için tasarlanmış bir medya oynatıcıdır:

- iPad 1
- iOS 5.1.1
- armv7
- yaklaşık 256 MB RAM
- Objective-C / UIKit
- non-ARC / manuel retain-release
- Theos
- eski iPhoneOS 6.1 SDK

Proje bilinçli olarak güncel medya oynatıcıların artık desteklemediği donanım ve işletim sistemi kısıtlarını hedefler.

## Uygulama ailesi sorumlulukları

iPad1Player, eski iPad 1 uygulama ailesinin bir parçasıdır.

Sorumluluklar:

- iPad1Files
  - dosya gezinme
  - arama
  - sıralama
  - favoriler
  - kopyala/taşı/sil/yeniden adlandır
  - klasörler
  - arşivler
  - dosya bilgisi

- iPad1Downloader
  - HTTP/HTTPS/FTP indirmeleri
  - kuyruk
  - ilerleme
  - devam ettirme
  - yeniden deneme

- iPad1PDFReader
  - PDF görüntüleme
  - gezinme
  - okuma
  - PDF yer imleri

- iPad1Player
  - demux
  - ses/video çözme
  - ses/video çıkışı
  - A/V senkronizasyonu
  - ileri sarma
  - devam ettirme
  - oynatma kontrolleri
  - altyazılar
  - iz seçimi
  - gecikme ayarları
  - bölümler
  - medya bilgisi
  - oynatma tanılaması
  - codec uyumluluğu
  - bellek güvenli tamponlama

Dosya yöneticisi, indirici veya PDF okuyucu sorumluluklarını iPad1Player'a taşıma.

Bkz.:

- `SUITE_HANDOFF.md`
- `docs/RESPONSIBILITY.md`

## URL scheme

Player açma adresi:

    ipad1player://open?path=<percent-encoded-local-path>

Yerel yolu iPad1Files gibi uygulama ailesindeki başka bir uygulama sağlar.

## Doğrulanmış güncel oynatma durumu

Gerçek iPad 1 cihaz testlerinde doğrulananlar:

- MKV konteyner ayrıştırma
- FFmpeg demux
- AAC ses çözme
- swresample dönüşümü
- 44.1 kHz stereo işaretli 16 bit PCM çıkışı
- AudioQueue ile oynatma
- 854x480'de H.264 yazılımsal çözme
- YUV420P AVFrame çıkışı
- OpenGL ES 2 YUV görüntüleyici
- Y/U/V doku yükleme
- shader tabanlı YUV'dan RGB'ye dönüşüm
- CAEAGLLayer sunumu
- eşzamanlı ses ve video oynatma
- sınırlı sıkıştırılmış video paket kuyruğu
- ayrılmış H.264 video çözme işçisi
- tek ve yalnızca tek `av_read_frame` demux okuyucusu
- kalıcı SwrContext
- en son kareyi tutan görüntüleyici geri basıncı
- önceki mikro donmalar olmadan kararlı 480p test oynatması

Gerçek cihaz test profili:

- H.264 Main
- 854x480
- yuv420p
- AAC LC
- 44.1 kHz
- stereo
- MKV

## Codec politikası

### Desteklenen / hedeflenen

- 854x480'e kadar H.264 yazılımsal çözme:
  `IPAD1_TEST_REQUIRED`

- AAC
- MP3
- MKV demux
- uyumlu olduğu yerde AVI demux
- uygun olduğu yerde eski MediaPlayer üzerinden yerleşik MP4/MOV/M4V yolu

### Hedeflenmeyen

- HEVC / H.265
- AV1
- VP9
- 4K
- HDR
- 10 bit video
- ağır ASS görüntüleme
- yalnız güncel donanımda çalışan formatlar

H.264 720p yazılımsal çözme reddedilmiş olarak kalır.

## Oynatma mimarisi

Güncel mimari:

    AVFormatContext
          |
          | one av_read_frame thread
          |
          +---- AAC packets
          |        |
          |        v
          |   AAC decoder
          |        |
          |   persistent swresample
          |        |
          |   PCM ring
          |        |
          |   AudioQueue
          |
          +---- H.264 packets
                   |
                   v
            bounded packet queue
                   |
                   v
            video decode worker
                   |
                   v
              YUV420P frame
                   |
                   v
          latest-frame renderer
                   |
                   v
             OpenGL ES 2

Aynı oynatma oturumu için asla iki bağımsız `av_read_frame` okuyucusu olmamalıdır.

## Önemli güncel sınırlamalar

Güncel oynatma uygulaması özellik açısından tamamlanmış sayılmaz.

Hâlâ eksik veya yarım olanlar:

- gerçek A/V senkronizasyonu
- video PTS zamanlaması
- gerçek AudioQueue sunum saati
- sağlam ileri sarma/temizleme
- dosya sonu (EOF) işleme
- temiz oynatma sonu durumu
- uzun süreli kararlılık doğrulaması
- FFmpeg oynatmayla üretim düzeyinde altyazı entegrasyonu
- gömülü altyazı seçimi
- ses izi değiştirme
- tam duraklat/devam davranışı
- zamanlamaya dayalı uygun kare atma politikası
- tanılama kodunun temizlenmesi
- iş parçacığı güvenli PCM halka tamponu
- AudioQueue KVC erişiminin kaldırılması
- FFmpeg adaptörünün genel oynatma yolu

## Güncel öncelik

Hemen yapılacak sonraki adım:

Şunları kullanarak zaman damgasına duyarlı A/V senkronizasyonu yaz:

- ana saat olarak ses
- video PTS
- sınırlı video zamanlaması
- kontrollü geç kare atma

Oynatma zamanlama yolu kararlı olmadan ilgisiz özelliklere başlama.

## Gerçek cihaz

Geliştirme/test cihazı:

- iPad 1
- iOS 5.1.1
- armv7

Eski SSH, ssh-rsa uyumluluk seçeneklerini gerektirir.

## Geliştirme kuralı

Her özellik için:

1. Uygulama ailesi sorumluluk filtresini uygula.
2. iPad 1 CPU/RAM etkisini kontrol et.
3. Sınırlı belleği tercih et.
4. Sınırsız kuyruklardan kaçın.
5. Gereksiz kopyalardan kaçın.
6. Gerçek iPad'de test et.
7. Bir özelliği yalnızca derlendiği için çalışıyor diye işaretleme.
