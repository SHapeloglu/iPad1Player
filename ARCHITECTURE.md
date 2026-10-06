# iPad1Player Mimarisi

## Tasarım hedefleri

iPad1Player, eski cihazın aşırı kısıtları için optimize edilmiştir:

- tek çekirdek sınıfında iPad 1 donanımı
- ~256 MB RAM
- iOS 5.1.1
- armv7
- eski OpenGL ES 2
- eski AudioQueue
- non-ARC Objective-C

Mimarinin öncelikleri:

- sınırlı bellek
- öngörülebilir CPU yükü
- en az kopyalama
- nazikçe performans düşürme (graceful degradation)
- uygulama ailesi sorumluluklarının ayrılması
- gerçek cihaz uyumluluğu

## Üst düzey oynatma hattı

    Local media path
          |
          v
    IP1MediaPreflight
          |
          v
    IP1MKVBackend
          |
          v
    IP1FFmpegAudioSession
          |
          +-----------------------------+
          |                             |
          v                             v
      demux thread                 video worker
      av_read_frame                    |
          |                            |
          |                     IP1FFmpegVideoDecoder
          |                            |
          |                         AVFrame
          |                            |
          |                        YUV420P
          |                            |
          |                     IP1YUVRendererView
          |
          v
    IP1FFmpegAudioDecoder
          |
          v
      SwrContext
          |
          v
    IP1AudioEngine
          |
          v
    IP1PCMRingBuffer
          |
          v
    IP1AudioQueueOutput

## Demux modeli

Şunu yalnızca tek bir iş parçacığı sahiplenir ve çağırır:

    av_read_frame()

Bu kesin bir mimari kuraldır.

Demux iş parçacığı paketleri akış numarasına göre yönlendirir.

Ses paketleri demux/ses yolunda kalır.

Video paketleri `av_packet_ref` ile kopyalanıp sınırlı bir kuyruğa aktarılır.

## Video paket kuyruğu

Sınıf:

    IP1PacketQueue

Güncel video kuyruğu politikası:

- en fazla öğe: 32
- en fazla sıkıştırılmış bayt: 4 MB
- iş parçacığı güvenli
- sınırlı
- H.264 çözmeyi tek bir işçi yapar

Referans kare bağımlılıkları sonraki çözülen görüntüleri bozabileceği için sıkıştırılmış H.264 paketlerinin rastgele atılmasından kaçınılır.

Kuyruk geçici olarak dolarsa demux iş parçacığı H.264 referans zincirini keyfi şekilde bozmak yerine kısa süre bekler.

İleride zamanlamaya dayalı atma, rastgele sıkıştırılmış referans paketi atmak yerine mümkün olduğunca çözülmüş kare düzeyinde yapılmalıdır.

## Video çözücü

Sınıf:

    IP1FFmpegVideoDecoder

Güncel hedef:

- AV_CODEC_ID_H264
- thread_count = 1
- yazılımsal çözme
- YUV420P

Çözücü en son çözülen AVFrame'i `av_frame_ref` ile tutar.

Bu gereklidir, çünkü tekrarlanan `avcodec_receive_frame` çağrılarına verilen çalışma `AVFrame`'i FFmpeg tarafından yeniden kullanılabilir/referansı bırakılabilir.

## Video görüntüleyici

Sınıf:

    IP1YUVRendererView

Teknoloji:

- CAEAGLLayer
- EAGLContext
- OpenGL ES 2
- GL_LUMINANCE dokuları
- Y/U/V düzlemleri
- fragment shader ile YUV -> RGB

Görüntüleyici bir üretici/arka tampon ve bir görüntüleme/ön tampon kullanır.

Politika:

    newest frame wins

(en yeni kare kazanır)

Aynı anda ana iş parçacığında yalnızca bir görüntüleme isteği planlanabilir.

Bu, `performSelectorOnMainThread` çağrılarının sınırsız birikmesini önler.

OpenGL işleri kare tamponu kilidi bırakıldıktan sonra yapılır.

Doku belleği boyut değişince `glTexImage2D` ile ayrılır.

Normal kare güncellemeleri şunu kullanır:

    glTexSubImage2D

## Ses çözücü

Sınıf:

    IP1FFmpegAudioDecoder

Çalışma zamanında desteklenen ses codec'leri şu an:

- AAC
- MP3

Çözülen ses libswresample ile şuna normalleştirilir:

- 44.1 kHz
- stereo
- işaretli 16 bit paketlenmiş PCM

SwrContext kalıcıdır ve yalnızca giriş/çıkış format parametreleri değişince yeniden oluşturulur.

Her AAC karesi için yeniden oluşturulmamalıdır.

## Ses çıkışı

Bileşenler:

    IP1AudioEngine
    IP1PCMRingBuffer
    IP1AudioQueueOutput

Güncel PCM halka tamponu:

- 256 KB

AudioQueue:

- üç tampon
- her biri 16 KB
- AVAudioSessionCategoryPlayback
- aktif AVAudioSession

## Saat

Sınıf:

    IP1PlaybackClock

Ana saatin (master clock) ses olması amaçlanır.

Güncel çözülmüş ses saati PCM yoluna yazılan baytlara dayanır, henüz gerçek donanım sunum saati değildir.

Bu ayrım bir sonraki A/V senkronizasyon aşaması için önemlidir.

## Yerleşik oynatma

MP4/MOV/M4V uygun olduğunda eski şunu kullanabilir:

    MPMoviePlayerController

FFmpeg çalışma zamanı şu an öncelikle eski yerleşik yolun yeterince işleyemediği konteyner/codec kombinasyonlarını hedefler.

## Bellek kuralları

iPad 1 için:

- sınırsız paket kuyruğu yok
- sınırsız kare kuyruğu yok
- tam RGB kare dönüşümünden kaçın
- UIImage ile video görüntülemekten kaçın
- büyük kare geçmişi yok
- tercihen yalnızca en son çözülen kare
- sıkıştırılmış kuyruklar küçük tutulur
- MRC altında açık temizlik

## İş parçacığı modeli

Amaçlanan güncel iş parçacıkları:

1. Ana/arayüz iş parçacığı
   - UIKit
   - OpenGL sunumu

2. FFmpeg demux/ses iş parçacığı
   - `av_read_frame`
   - AAC/MP3 çözme
   - PCM'i kuyruğa ekleme

3. Video çözme işçisi
   - H.264 çözme
   - çözülen kareyi teslim etme

4. AudioQueue iç geri çağrı iş parçacığı
   - PCM tüketimi

İkinci bir demux okuyucusuna izin yoktur.

## Bilinen teknik borç

- PCM halka tamponu henüz tam iş parçacığı güvenli değil.
- AudioQueue geri çağrısı PCM halkasına KVC ile erişiyor.
- ses saati gerçek sunum konumu değil.
- FFmpeg ileri sarma/temizleme eksik.
- video PTS henüz sunum zamanlamasında kullanılmıyor.
- dosya sonu (EOF) için açık "oynatma tamamlandı" işlemi gerekiyor.
