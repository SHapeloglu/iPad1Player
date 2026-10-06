# iPad1Player v0.1-alpha18

**iPad 1 / iOS 5.1.1 / armv7 / ~256 MB RAM / Objective-C / UIKit / non-ARC/MRC / Theos** için eski cihaz medya oynatıcısı.

## Uygulama ailesi sorumluluk sınırı

iPad1Player yalnızca **medya oynatmadan** sorumludur. Dosya gezinme/yönetimi, indirme veya PDF okumayı çoğaltmaz.

- Dosya yönetimi -> `iPad1Files`
- İndirmeler -> `iPad1Downloader`
- PDF okuma -> `iPad1PDFReader`
- Video/ses oynatma -> `iPad1Player`

Bkz. `SUITE_HANDOFF.md` ve `docs/RESPONSIBILITY.md`.

## alpha4'e kadar yapılanlar

### Yerleşik MP4/MOV/M4V oynatma
- Apple `MPMoviePlayerController` altyapısı.
- Oynat/duraklat/yerleşik ileri sarma kontrolleri.
- Son konumdan devam; tamamlanan medya devam durumunu temizler.
- Oynatma sırasında otomatik uyku kapalı.
- Döndürme desteği.

### İleri sarma ve konfor
- Sola/sağa kaydırma: -10 / +10 saniye.
- Oynatma hızı döngüsü: 1.0x, 1.25x, 1.5x, 0.5x.
- A-B tekrar işaretleri ve temizleme.
- Kontrol kilidi.
- Sol yarıda dikey hareket: parlaklık.
- Sağ yarıda dikey hareket: ses düzeyi.

### En-boy oranı
- Sığdır
- Doldur
- 4:3
- 16:9
- 1.85:1
- 2.35:1

### Harici altyazılar
- `.srt` ayrıştırma.
- Yan dosyaları otomatik bulma:
  - `Movie.srt`
  - `Movie-tr.srt`
  - `Movie-en.srt`
  - `Movie.tr.srt`
- Eşleşen harici altyazı dosyaları arasında geçiş.
- Altyazıyı aç/kapat.
- 0,5 saniyelik adımlarla zaman kaydırma.
- Yazı boyutu ayarı.
- Dikey konum ayarı.
- Kodlama döngüsü:
  - Otomatik
  - UTF-8
  - Windows-1254
  - ISO-8859-9
- Türkçe karakter desteği.

### Medya bilgisi
Yerleşik altyapı dosya/konteyner, çözünürlük, süre ve altyapı türünü gösterir. Codec/iz ayrıntıları FFmpeg bağlandığında genişletilecek.

## MKV / FFmpeg altyapı sınırı

`IP1MKVBackend` artık açık bir yetenek sınırıdır. Arayüz, mevcut olmayan FFmpeg bağımlı özellikleri çalışıyormuş gibi göstermez.

Hâlâ gerçek eski FFmpeg/hibrit altyapı gerektirenler:

- MKV demux/oynatma.
- MKV'den AAC/MP3 ses çözme.
- Gömülü altyazı izleri.
- Gömülü ASS/SSA görüntüleme.
- Birden fazla ses izi seçimi.
- Birden fazla gömülü altyazı izi seçimi.
- Ses gecikmesi.
- Ayrıntılı codec/fps/bit hızı tanılaması.
- Düşük bellekli paket/kare kuyrukları.
- A4/iOS 5.1.1 için H.264 hibrit/donanım destekli yol araştırması.

> Önemli: iOS 5.1.1 için güncel VideoToolbox varsayımları kullanılmamalıdır. Donanım destekli her H.264 yolu gerçek eski cihaz/API kısıtlarına göre yazılıp test edilmelidir.

## Dışarıdan açma

```text
ipad1player://open?path=<percent-encoded-absolute-local-media-path>
```

Oynatıcı dosya yöneticisine dönüşmek yerine medya olmayan dosyaları reddeder.

## Derleme

```bash
make clean
make package FINALPACKAGE=1
```


## alpha4'te eklenenler

- Açık MKV altyapı yaşam döngüsü sözleşmesi: aç/oynat/duraklat/durdur/ileri sar/zaman/süre.
- Video/ses/altyazı akışları için iz modeli.
- Çoklu ses ve gömülü altyazı seçimi alanları.
- Altyapı API'sinde ses/altyazı gecikmesi alanları.
- Çözme modu sözleşmesi: Otomatik / Yazılım / Eski Donanım.
- Sınırlı, düşük bellekli paket kuyruğu.
- Proje sağlayıcı kütüphaneler olmadan da derlensin diye FFmpeg derleme kancaları isteğe bağlı tutuldu.
- MKV hattı ve A/V senkronizasyon tasarımı `docs/MKV_BACKEND.md`'de belgelendi.

### Yanlışlıkla tamamlandı denmeyenler

Uyumlu FFmpeg armv7 kütüphaneleri ve adaptör bağlanıp cihazda test edilene kadar gerçek MKV oynatma **tamamlandı olarak işaretlenmez**. Eski H.264 donanım hızlandırması da gerçek bir iPad 1'de doğrulanana kadar desteklenir sayılmaz.


## alpha5'te eklenenler — sektörle hizalama

- Kodda merkezi yetenek/codec matrisi eklendi.
- AVI, oynatma desteği varmış gibi gösterilmeden gelecekteki FFmpeg destekli konteyner olarak eklendi.
- Arayüzden ve uygulama ailesi yönlendirmesinden ayrı, açık bir FFmpeg adaptör sınırı eklendi.
- iPad 1 bellek sınırları için temkinli paket bütçeleri eklendi.
- FFmpeg oynatma için ileri sarmada temizleme (seek-flush) sözleşmesi eklendi.
- P0/P1/P2/P3 yol haritası ve codec matrisi dokümantasyonu eklendi.
- 1. seviye hedef codec'ler: H.264 + AAC/MP3 + SRT/ASS/SSA.
- 2. seviye hedefler: AVI + MPEG-4 Part 2/Xvid + AC3/E-AC3.
- iPad 1 hedefi için HEVC/AV1/VP9/4K/HDR açıkça reddedildi.

Bkz.:
- `docs/SECTOR_ROADMAP.md`
- `docs/CODEC_MATRIX.md`


## alpha6'da eklenenler

- Bölüm (chapter) modeli ve altyapı sözleşmesi.
- Ayrıntılı medya bilgisi modeli.
- Uyku zamanlayıcısı API'si.
- Genişletilmiş oynatma hızı hedefleri: 0.5x / 0.75x / 1.0x / 1.25x / 1.5x / 2.0x.
- Sektör yol haritası güncellendi: bölümler ve ayrıntılı medya bilgisi P1, uyku zamanlayıcısı ve 2.0x hız P2.
- FFmpeg bölüm çıkarma altyapıya bağlı kalıyor ve yanlışlıkla tamamlandı diye işaretlenmedi.


## alpha7'de eklenenler — iPad 1 optimizasyon ve uyumluluk

- Altyazı arama tam liste taramasından şuna geçti:
  - normal sıralı oynatmada O(1) hızlı yol.
  - ileri sarma/atlama sonrası O(log n) ikili arama.
- Devam konumu kaydetme aralığı 5 saniyeden 30 saniyeye çıkarıldı.
- Zorunlu `NSUserDefaults synchronize` kaldırıldı.
- Devam durumu uygulama arka plana geçince/kapanınca da kaydediliyor.
- Uyku zamanlayıcısı ortak zamanlayıcı temizlik yolunda iptal ediliyor.
- Oynatıcı ekran parlaklığını değiştirdiyse oynatmadan çıkınca orijinal parlaklık geri yükleniyor.
- Ses hareketi artık ayrı bir uygulama müzik çalar oturumunu değil film oynatıcıyı hedefliyor.
- Oynatma hızı listesi artık gerçekten 0.5x / 0.75x / 1.0x / 1.25x / 1.5x / 2.0x içeriyor.
- Kod düzeyinde `IP1CompatibilityGate` eklendi.
- Özellikler şöyle sınıflandırılıyor:
  - `IPAD1_SAFE`
  - `IPAD1_TEST_REQUIRED`
  - `IPAD1_REJECTED`

Proje, `IPAD1_TEST_REQUIRED` özellikleri gerçek bir iPad 1'de test edilmeden kanıtlanmış diye sunmamalıdır.


## alpha8'de eklenenler — oynatma motoru sözleşmesi

- `IP1PlaybackClock` eklendi.
- Render / Bekle / At kararlarıyla `IP1FramePolicy` eklendi.
- FFmpeg adaptör yaşam döngüsü artık play/pause/currentTime/duration içeriyor.
- İz değiştirme sözleşmesi artık ses/altyazı akışı seçimini destekliyor.
- MKV altyapısı oynat/duraklat/durdur/ileri sar ve iz seçimini adaptöre iletiyor.
- Açık A/V ana saat (master clock) ve geç kalan kareyi atma mimarisi eklendi.
- `docs/PLAYBACK_ENGINE.md` eklendi.

Gerçek FFmpeg demux/çözme hâlâ altyapıya bağlı; alpha8 MKV oynatmanın tamamlandığını iddia etmiyor.


## alpha9'da eklenenler — sınırlı FFmpeg ayrıştırma aşaması

- Yalnızca ayrıştırma yapan FFmpeg sözleşmesi eklendi.
- `IP1FFmpegParseResult` eklendi.
- iPad 1 için savunmacı ayrıştırma politikası eklendi.
- Açık iz/bölüm sayısı sınırları eklendi.
- Cihaz testi durum modeli eklendi.
- Alpha9 bilinçli olarak video/ses çözmüyor.
- FFmpeg bağlamları metadata çıkarıldıktan hemen sonra kapatılmalı.

Bkz. `docs/ALPHA9_PARSE_PHASE.md`.


## alpha10'da eklenenler — iPad 1 sıkılaştırması

- Merkezi düşük bellek bütçesi sınıfı.
- Daha temkinli FFmpeg paket bütçeleri.
- Bellek uyarısında kuyruk kırpma.
- Oynatıcı düzeyinde düşük bellek temizliği.
- Varsayılan olarak 1.5x ile sınırlı güvenli oynatma hızı profili.
- Daha sıkı metadata/iz/bölüm ayrıştırma sınırları.
- `docs/ALPHA10_IPAD1_HARDENING.md` eklendi.

Bu aşamada yeni ağır codec özelliği eklenmedi.


## alpha11'de eklenenler — iPad 1 ayrıştırma çalışma zamanı kapısı

- Ayrıştırma tanılama modeli eklendi.
- Sınırlı akış metadata eşleyicisi eklendi.
- Ayrıştırma süresi ve medya süresi için makullük sınırları eklendi.
- `parseAndCloseMediaAtPath` sözleşmesi eklendi.
- Yalnız ayrıştıran altyapı artık metadata çıkarıldıktan sonra durumu açıkça kapatıyor.
- Metadata başlık/dil sınırlama kuralları eklendi.
- Hiçbir çözme/görüntüleme/ses özelliği açılmadı.

Bkz. `docs/ALPHA11_PARSE_RUNTIME_GATE.md`.


## alpha12'de eklenenler — FFmpeg entegrasyon öncesi kapı

- Derleme yeteneği raporlama eklendi.
- Ayrıştırma sonucu doğrulaması eklendi.
- Açık yerleşik/FFmpeg geri dönüş politikası eklendi.
- Daha sıkı ayrıştırma reddetme davranışı eklendi.
- Gerçek iPad 1 entegrasyon kontrol listesi eklendi.
- Hâlâ çözme/görüntüleme/ses açılmadı.

Bkz. `docs/ALPHA12_PREINTEGRATION.md`.


## alpha13'te eklenenler — iPad 1 sağlamlığı

- Medya ön kontrolleri eklendi.
- Bozuk/makul olmayan metadata reddi eklendi.
- Sınırlı tekrarlı ayrıştır/kapat yük testi düzeneği eklendi.
- MRC için her döngüde autorelease pool boşaltma eklendi.
- Çözme/ses/görüntüleme yeteneği açılmadı.

Bkz. `docs/ALPHA13_ROBUSTNESS.md`.


## alpha14'te eklenenler — gerçek libavformat ayrıştırma kaynağı

`IP1_FFMPEG_BACKEND` uyumlu armv7 kütüphaneleriyle açıldığında adaptör artık bir konteyneri açmak, izleri listelemek, bölümleri çıkarmak ve medya bilgisini doldurmak için gerçek libavformat API'lerini kullanıyor; ardından format bağlamını hemen kapatıyor.

- Eski/yeni FFmpeg akış metadata uyumluluk yardımcıları eklendi.
- Gerçek akış ve bölüm eşlemesi eklendi.
- Derleme raporuna FFmpeg sürüm bilgisi eklendi.
- Sağlayıcı (vendor) klasör düzeni dokümantasyonu eklendi.
- Hâlâ H.264/AAC çözme veya görüntüleyici yok.

Bkz. `docs/ALPHA14_REAL_PARSE.md`.


## alpha15'te eklenenler — Player kapsamı + ses temeli

- Kod düzeyinde uygulama ailesi sorumluluk kapısı eklendi.
- Sınırlı 256 KB PCM halka tampon eklendi.
- Temkinli iPad 1 ses çalışma zamanı profili eklendi.
- Player'a ait ses motoru sınırı eklendi.
- Files/PDFReader/Downloader sorumlulukları açıkça Player'ın dışında tutuldu.
- 480p yazılımsal H.264 yalnızca test aşamasında; 720p yazılımsal birincil yol reddedilmiş olarak kalıyor.

Bkz. `docs/ALPHA15_SCOPE_AND_AUDIO.md`.


## alpha16'da eklenenler — MKV/H.264 iPad 1 politikası

- MKV/H.264 oynatma artık açıkça Player'ın sorumluluğu.
- Merkezi H.264 çözme karar politikası eklendi.
- Hedeflenen test 360p/480p yazılımsal çözme.
- 720p yazılımsal çözme birincil yol olarak reddedildi.
- 720p yalnızca doğrulanmış eski donanım/hibrit yolla izinli.
- Video çözme yeteneği raporlama eklendi.

Desteklenmeyen hiçbir çözücü açılmadı.

Bkz. `docs/ALPHA16_H264_POLICY.md`.


## alpha17'de eklenenler — düşük bellekli ses çalışma zamanı

- iOS 5 uyumlu AudioQueue PCM çıkışı eklendi.
- 3 x 16 KB AudioQueue tamponu eklendi.
- Sınırlı 256 KB PCM halka tampon korundu.
- Altyapı bayrağının arkasında FFmpeg AAC/MP3 çözücü kaynağı eklendi.
- Eski/yeni FFmpeg ses çözme dalları eklendi.
- S16 dışı örnek formatları swresample testi bekleniyor olarak kapalı kaldı.
- Uygulama ailesi sorumluluk sızıntısı yok.

Bkz. `docs/ALPHA17_AUDIO_RUNTIME.md`.


## alpha18'de eklenenler — uçtan uca ses döngüsü

- Seçilen akış için `av_read_frame` döngüsü eklendi.
- Tek, düşük bellekli ses demux iş parçacığı eklendi.
- AAC/MP3 çözücü sınırlı PCM halka tampon ve AudioQueue'ya bağlandı.
- Daha fazla paket çözmeden önce PCM geri basıncı (backpressure) eklendi.
- Kabul edilen PCM baytlarına göre ilerleyen ses ana saati eklendi.
- Açık MKV altyapısı ses çalışma zamanı giriş noktaları eklendi.
- Video çözme açılmadı.

Bkz. `docs/ALPHA18_AUDIO_LOOP.md`.


## Geliştirme dokümantasyonu

Geliştirme ve devir belgeleri:

- `PROJECT_CONTEXT.md` — belirleyici güncel proje durumu
- `ARCHITECTURE.md` — oynatma ve iş parçacığı mimarisi
- `SESSION.md` — son gerçek cihaz geliştirme oturumu
- `TASK.md` — hemen yapılacak geliştirme görevleri
- `BACKLOG.md` — önceliklendirilmiş gelecek işler
- `SUITE_HANDOFF.md` — uygulama ailesi entegrasyonu ve sorumluluk devri
- `docs/RESPONSIBILITY.md` — uygulama sorumluluk sınırları
