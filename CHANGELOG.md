# Değişiklik Günlüğü

## v0.1-alpha18
- av_read_frame seçilen AAC/MP3 çözücüye bağlandı.
- Çözülen S16 PCM sınırlı halka tampona ve AudioQueue'ya bağlandı.
- Tek iş parçacıklı, düşük bellekli demux döngüsü eklendi.
- PCM doluluk geri basıncı eklendi.
- Ses ana saati ilerlemesi eklendi.
- Uygulama ailesi sorumluluk sınırları korundu.

## v0.1-alpha17
- Düşük bellekli AudioQueue çıkışı eklendi.
- FFmpeg AAC/MP3 çözücü kaynağı eklendi.
- 3x16 KB çıkış tamponu politikası eklendi.
- 256 KB sınırlı PCM halka tampon korundu.
- Uygulama ailesi sorumluluk sınırları korundu.
- FFmpeg kütüphaneleri harici kalıyor; cihaz testi gerekiyor.

## v0.1-alpha16
- MKV/H.264 oynatma açıkça Player kapsamı olarak ilan edildi.
- Merkezi H.264 çözünürlük/çözme politikası eklendi.
- 360p/480p yazılımsal test hedefleri eklendi.
- 720p yazılımsal birincil yol reddedilmiş olarak kaldı.
- Eski donanım/hibrit 720p test kapısı eklendi.
- Çözme yeteneği raporlama eklendi.

## v0.1-alpha15
- Kod düzeyinde uygulama ailesi kapsam denetimi eklendi.
- Sınırlı PCM halka tampon eklendi.
- Temkinli ses çalışma zamanı profili eklendi.
- Ses motoru sınırı eklendi.
- iPad1Files / iPad1PDFReader / iPad1Downloader ayrımı korundu.
- Desteklenmeyen çözme iddiası eklenmedi.

## v0.1-alpha14
- FFmpeg ayrıştırma taslağı, derleme bayrağı arkasında gerçek libavformat ayrıştırma kaynağıyla değiştirildi.
- Eski/yeni FFmpeg AVStream uyumluluk yardımcıları eklendi.
- Gerçek iz/bölüm/medya bilgisi eşlemesi eklendi.
- FFmpeg derleme sürümü raporlama eklendi.
- Bağlamı hemen kapatma ve sıfır çözmeli ayrıştırma politikası korundu.
- FFmpeg statik kütüphaneleri bilinçli olarak pakete eklenmedi.

## v0.1-alpha13
- Dosya/yol ön kontrol doğrulaması eklendi.
- Bozuk metadata için makullük sınırları eklendi.
- Sınırlı ayrıştır/kapat yük testi düzeneği eklendi.
- MRC dostu, her döngüde autorelease pool eklendi.
- Codec/çözme/görüntüleme özellikleri kapalı tutuldu.

## v0.1-alpha12
- FFmpeg derleme kontrolleri eklendi.
- Ayrıştırma sonucu doğrulaması eklendi.
- Ayrıştırma geri dönüş politikası eklendi.
- iPad 1 için sıkı entegrasyon öncesi kontrol listesi eklendi.
- Çözme/görüntüleme/ses kapalı tutuldu.

## v0.1-alpha11
- Ayrıştırma tanılamaları eklendi.
- Ayrıştırma süresi ve medya süresi makullük sınırları eklendi.
- Sınırlı akış metadata normalleştirmesi eklendi.
- Ayrıştır-ve-kapat çalışma zamanı sözleşmesi eklendi.
- Çözme/görüntüleme/ses kapalı tutuldu.
- iPad 1 ayrıştırma güvenlik kapısı güçlendirildi.

## v0.1-alpha10
- Merkezi iPad 1 bellek bütçeleri eklendi.
- Sıkıştırılmış paket bütçeleri azaltıldı.
- Bellek baskısında paket kuyruğu kırpma eklendi.
- Oynatıcı düşük bellek temizliği eklendi.
- Varsayılan oynatma hızları güvenli 0.5x–1.5x profiline çekildi.
- Ayrıştırma metadata, iz ve bölüm sınırları sıkılaştırıldı.
- 2.0x varsayılan yerine TEST_REQUIRED olarak tutuldu.

## v0.1-alpha9
- Düşük bellekli, yalnız ayrıştıran FFmpeg aşaması sözleşmesi eklendi.
- İz/bölüm/medya bilgisi için ayrıştırma sonucu modeli eklendi.
- Savunmacı ayrıştırma politikası ve sınırları eklendi.
- Cihaz testi durum modeli eklendi.
- Yalnız ayrıştırma aşamasında paket tamponlama/kare çözme açıkça reddedildi.

## v0.1-alpha8
- Oynatma saati modeli eklendi.
- Video karesi görüntüle/bekle/at politikası eklendi.
- FFmpeg adaptör yaşam döngüsü genişletildi.
- Ses/altyazı izi değiştirme sözleşmeleri eklendi.
- MKV altyapı yaşam döngüsü adaptöre yönlendirildi.
- A/V senkronizasyon, ileri sarma ve kare atma mimarisi belgelendi.

## v0.1-alpha7
- iPad 1 uyumluluk kapısı ve durum matrisi eklendi.
- Altyazı arama O(1) sıralı / O(log n) ileri sarma yoluna optimize edildi.
- Devam konumu kaydetme sıklığı 5 sn'den 30 sn'ye düşürüldü.
- Zorunlu NSUserDefaults senkronizasyonu kaldırıldı.
- Arka plana geçişte/kapanışta devam konumu kaydı eklendi.
- MRC yaşam döngüsünde uyku zamanlayıcısı temizliği düzeltildi.
- Oynatma sonrası parlaklığı geri yükleme eklendi.
- Ses hareketi film oynatmayı hedefleyecek şekilde değiştirildi.
- Gerçek oynatma hızı ön ayarları 2.0x'e kadar düzeltildi.
- Cihaza duyarlı özellikler TEST_REQUIRED olarak işaretlendi.

## v0.1-alpha6
- Bölüm modeli eklendi.
- Ayrıntılı medya bilgisi modeli eklendi.
- Uyku zamanlayıcısı API'si eklendi.
- Oynatma hızı hedefleri 2.0x'e kadar genişletildi.
- FFmpeg/MKV altyapı sözleşmeleri bölümler ve ayrıntılı medya bilgisi için genişletildi.
- Sektör yol haritası öncelikleri güncellendi.

## v0.1-alpha5
- Medya yetenek/codec matrisi eklendi.
- FFmpeg adaptör sınırı eklendi.
- AVI altyapı yönlendirme yolu eklendi.
- Sınırlı FFmpeg paket bütçeleri ve ileri sarmada temizleme sözleşmesi eklendi.
- Sektör yol haritası ve codec matrisi dokümanları eklendi.
- P0/P1/P2/P3 öncelikleri resmileştirildi.
- Eski format hedefleri ve güncel codec'lerin hedef dışı olduğu resmileştirildi.

## v0.1-alpha4
- MKV altyapı yaşam döngüsü API'si eklendi.
- Medya izi modeli eklendi.
- Düşük bellekli çalışma için sınırlı paket kuyruğu eklendi.
- Çoklu ses / gömülü altyazı / gecikme yetenek sözleşmeleri eklendi.
- Çözme modu modeli ve eski donanım yetenek kapısı eklendi.
- İsteğe bağlı FFmpeg derleme kancaları eklendi.
- MKV hattı, A/V senkronizasyonu ve bellek bütçesi dokümantasyonu eklendi.
- Uygulama ailesi sorumluluk sınırları korundu.

## v0.1-alpha3
- Rakiplerden esinlenen oynatma kontrolleri, altyazı deneyimi, hareketler, en-boy oranları, hız, A-B tekrar ve medya bilgisi.
