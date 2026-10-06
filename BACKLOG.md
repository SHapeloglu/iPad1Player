# iPad1Player İş Havuzu

## P0 — Oynatma doğruluğu

- [ ] Video PTS çıkarma
- [ ] Ses ana saatli A/V senkronizasyonu
- [ ] Geç kalan çözülmüş kareyi atma politikası
- [ ] EOF'ta çözücü temizleme
- [ ] Temiz "oynatma tamamlandı" olayı
- [ ] Duraklat/devam yaşam döngüsü doğrulaması
- [ ] FFmpeg ileri sarma uygulaması
- [ ] İleri sarma sonrası ses/video çözücü temizleme
- [ ] İleri sarma sonrası paket kuyruğu temizleme

## P1 — Kararlılık

- [ ] PCM halka tamponunu tam iş parçacığı güvenli yap
- [ ] AudioQueue geri çağrısındaki KVC erişimini kaldır
- [ ] AudioQueueStart hatalarını yukarı ilet
- [ ] Video işçisi kapanışındaki yarış durumu güvenliğini doğrula
- [ ] Tekrarlı aç/kapat oynatmayı doğrula
- [ ] Uygulamayı yeniden başlatmadan tekrarlı MKV değişimini doğrula
- [ ] Bellek uyarısı davranışı
- [ ] 10 dakikalık gerçek cihaz oynatma testi
- [ ] 30 dakikalık gerçek cihaz oynatma testi
- [ ] Tam film oynatma testi

## P1 — Video

- [ ] Doğru en-boy sığdırma geometrisi
- [ ] En-boy doldurma
- [ ] Görüntüleyici yeniden boyutlandırma/yön değişimi
- [ ] Kare zamanlama tanılaması
- [ ] Atılan kare istatistikleri
- [ ] Paket kuyruğu istatistikleri
- [ ] OpenGL hata tanılaması
- [ ] Gerekirse YUV renk aralığı işleme

## P1 — Ses

- [ ] Gerçek AudioQueue sunum saati
- [ ] Ses tampon boşalması (underrun) tanılaması
- [ ] FFmpeg çalışma zamanında ses gecikmesi ayarı
- [ ] Birden fazla gömülü ses izi arasında geçiş
- [ ] MP3 çalışma zamanı doğrulaması
- [ ] Örnekleme hızı dönüşümü doğrulaması

## P2 — Altyazılar

- [ ] Mevcut SRT ayrıştırıcıyı FFmpeg oynatma saatiyle bütünleştir
- [ ] Altyazı gecikmesi
- [ ] Altyazı aç/kapat
- [ ] Gömülü altyazı bulma
- [ ] Gömülü altyazı seçimi
- [ ] Bellek güvenli altyazı dizinleme

Ağır ASS görüntüleme proje hedefi değildir.

## P2 — Oynatma deneyimi

- [ ] FFmpeg çalışma zamanına bağlı ilerleme çubuğu
- [ ] Devam konumu
- [ ] Bölüm gezinme
- [ ] Oynatma bilgisi katmanı
- [ ] Ses izi seçici
- [ ] Altyazı izi seçici
- [ ] Oynatma tanılama ekranı
- [ ] Geçici GL tanılama etiketlerini temizle

## P2 — Mimari temizlik

- [ ] Gerekirse video paket sarmalayıcısını ayrı kaynak dosyaya taşı
- [ ] IP1FFmpegAdapter sorumluluğunu netleştir
- [ ] Kalan deneysel baypasları değiştir
- [ ] Eskimiş Alpha14/Alpha18 yorumlarını güncelle
- [ ] Üretim düzeyinde FFmpeg oynatma arayüzünü tanımla
- [ ] MRC altında stop/dealloc sahipliğini gözden geçir

## P3 — Uyumluluk testleri

Gerçek cihaz test matrisi:

- [x] H.264 854x480 + AAC MKV
- [ ] H.264 640x360 + AAC MKV
- [ ] H.264 854x480 + MP3 MKV
- [ ] Uyumlu AVI video/ses
- [ ] Değişken kare hızlı H.264
- [ ] Politika içindeki farklı H.264 profilleri
- [ ] Bozuk medya işleme

## Açıkça kapsam dışı

Ekleme:

- HEVC / H.265
- AV1
- VP9
- 4K
- HDR
- 10 bit oynatma
- bulut dosya yöneticisi
- indirici özellikleri
- PDF okuyucu
- genel dosya yöneticisi işlevleri
- ağır ASS efektleri
