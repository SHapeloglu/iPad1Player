# Geliştirme Oturumu

## Oturum: Gerçek iPad 1'de çalışan FFmpeg video oynatma

Bu oturumda mevcut FFmpeg ses çalışma zamanı, gerçek bir iPad 1'de çalışan ses/video MKV oynatma hattına dönüştürüldü.

## Başlangıç durumu

Projede zaten şunlar vardı:

- FFmpeg 4.4 armv7 statik kütüphaneleri
- MKV ayrıştırma
- AAC/MP3 ses çözme
- swresample
- AudioQueue çıkışı
- duyulabilir çalışan MKV sesi

Video için görüntüleyici yoktu.

İlk testte kullanılan film şuydu:

- HEVC
- 1280x720
- AAC

HEVC/720p proje kapsamı dışında.

Bu yüzden özel bir test dosyası hazırlandı:

- H.264 Main
- 854x480
- yuv420p
- AAC LC
- 44.1 kHz stereo
- MKV

## H.264 çözme doğrulaması

Tanılama amaçlı bir H.264 çözücü eklendi.

Gerçek cihaz sonucu şu tür çözülmüş kareler gösterdi:

    Video 75 frame 854x480

Bu, iPad 1'de H.264 yazılımsal çözmenin çalıştığını kanıtladı.

## OpenGL ES 2 görüntüleyici

Eklenenler:

    IP1YUVRendererView.h
    IP1YUVRendererView.m

Görüntüleyici:

- YUV420P kabul eder
- Y/U/V düzlemlerini güvenle kopyalar
- üç GL_LUMINANCE dokusu yükler
- shader'da YUV'u RGB'ye çevirir
- CAEAGLLayer ile sunar

İlk başta ekran siyah kaldı.

## AVFrame yaşam süresi hatası

Çözülen kare sayısı artıyordu ama görüntüleyiciye hiçbir YUV geri çağrısı ulaşmıyordu.

Neden:

Çözücü, tekrarlanan `avcodec_receive_frame()` çağrılarından sonra `_frame`'i dışarı veriyordu.

Çalışma AVFrame'i yeniden kullanılabiliyor/referansı bırakılabiliyordu.

Düzeltme:

- `_lastFrame` eklendi
- `av_frame_ref(_lastFrame, _frame)`
- görüntüleyici tutulan kareden okuyor

Sonuç:

Fiziksel iPad 1'de gerçek video görüntüsü başarıyla göründü.

## Görüntüleyici geri basıncı

İlk oynatmada daha sonra hem sesi hem videoyu etkileyen donmalar görüldü.

Neden:

- çok fazla ana iş parçacığı görüntüleme isteği
- kare kilidi tutulurken GL işi yapılması
- demux iş parçacığının bloklanabilmesi

Düzeltme:

- üretici/görüntüleme çift tamponu
- `_drawScheduled`
- yalnızca bir bekleyen arayüz görüntüleme isteği
- en yeni kare kazanır politikası
- OpenGL işinden önce kilidi bırakma

Sonuç:

Oynatma çok daha güvenilir ilerledi.

## Doku yükleme optimizasyonu

İlk görüntüleyici her karede `glTexImage2D` kullanıyordu.

Şuna değiştirildi:

- yalnızca ayırma/boyut değişiminde `glTexImage2D`
- normal kare güncellemelerinde `glTexSubImage2D`

Bu gereksiz doku yeniden oluşturmayı azalttı, ancak tek başına tüm mikro takılmaları gidermedi.

## Kalıcı SwrContext

Ses çözücü önceden çözülen her ses karesi için şunları yapıyordu:

    swr_free
    swr_alloc_set_opts
    swr_init

Kalıcı SwrContext'e geçildi.

Bağlam yalnızca şu durumlarda yeniden oluşturuluyor:

- giriş kanal düzeni değişince
- giriş örnek formatı değişince
- giriş örnekleme hızı değişince
- çıkış düzeni/hızı/kanalları değişince

Bu doğru bir optimizasyondu ama kalan takılmaların ana nedeni değildi.

## Ayrı video çözme işçisi

Asıl performans sorunu mimariydi.

Önceden:

    av_read_frame
      -> H264 decode
      -> AAC decode

Video çözme gecikmesi ses paketi işlemeyi geciktiriyordu.

Yapılan:

    single av_read_frame
          |
          +-> audio decode
          |
          +-> bounded video packet queue
                    |
                    v
              video worker
                    |
                    v
               H264 decode

Sonuç:

Mikro donmalar ortadan kalktı.

## H.264 paket bozulması

İlk işçi kuyruğu küçüktü ve dolunca sıkıştırılmış H.264 paketlerini atıyordu.

Oynatma akıcı hale geldi ama videoda ciddi bozulma/bloklanma görüldü.

Neden:

Rastgele sıkıştırılmış H.264 paket kaybı, kareler arası referans bağımlılıklarını bozar.

Düzeltme:

- kuyruk 32 pakete çıkarıldı
- 4 MB sıkıştırılmış bayt sınırı
- keyfi H.264 paket atma kaldırıldı
- kuyruk doluyken kısa yeniden deneme/bekleme

Sonuç:

Gerçek cihaz testi:

- akıcı oynatma
- temiz görüntü
- ses doğru şekilde devam ediyor
- önceki mikro donmalar yok

## Güncel doğrulanmış kilometre taşı

Aşağıdaki hat artık gerçek bir iPad 1'de çalışıyor:

    MKV
      |
    FFmpeg demux
      |
      +--> AAC --> PCM --> AudioQueue
      |
      +--> bounded H264 packet queue
               |
          video worker
               |
           H264 decode
               |
            YUV420P
               |
          OpenGL ES 2
               |
            display

## Sıradaki geliştirme alanı

Hemen ilgisiz özellikler ekleme.

Sıradaki öncelik:

Şunlarla A/V senkronizasyonu:

- video PTS
- ses ana saati
- kare zamanlaması
- geç kare işleme
