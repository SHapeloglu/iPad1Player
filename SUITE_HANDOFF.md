# iPad1 Uygulama Ailesi Sorumluluk Devir Günlüğü

Bu belge, **iPad1Player** geliştirilirken Player kapsamı dışında bırakılan işleri ve bu işlerin iPad1 uygulama ailesinde hangi uygulamaya yönlendirileceğini tanımlar.

## Temel Kural

Bir özellik iPad1 uygulama ailesindeki başka bir uygulamanın ana sorumluluğundaysa, **iPad1Player içinde yeniden geliştirilmez**. Kullanıcı uygun uygulamaya yönlendirilir.

---

## 1. iPad1Files'a Yönlendirilecek İşler

Aşağıdaki özellikler **iPad1Files** sorumluluğundadır ve iPad1Player içinde uygulanmamalıdır:

- Dosya ve klasör gezme
- Dosya listeleme
- Dosya arama
- A-Z / Z-A sıralama
- Dosya kopyalama
- Dosya taşıma
- Dosya silme
- Dosya yeniden adlandırma
- Klasör oluşturma
- Dosya bilgi ekranı
- Favoriler
- ZIP / arşiv işlemleri
- Genel dosya yönetimi
- Kullanıcının medya dosyasını klasörlerden bulması

### Player davranışı

Player yalnızca kendisine verilen medya yolunu açar.

Örnek yönlendirme:

```text
ipad1player://open?path=/var/mobile/Media/Movies/film.mkv
```

Player'a medya dışı genel bir dosya verilirse dosya yönetimi yapmaz; iPad1Files'a yönlendirme önerir.

---

## 2. iPad1Downloader'a Yönlendirilecek İşler

Aşağıdaki özellikler **iPad1Downloader** sorumluluğundadır:

- İnternetten medya indirme
- HTTP / HTTPS indirme
- FTP üzerinden indirme
- İndirme kuyruğu
- İndirme ilerleme göstergesi
- İndirmeyi durdurma
- İndirmeye devam etme
- Yeniden deneme
- İndirme geçmişi
- Uzak URL'den dosya kaydetme

### Player davranışı

Player indirme motoru içermez.

Bir medya URL'si indirilmek istenirse Downloader'a yönlendirilir.

Örnek:

```text
ipad1downloader://download?url=http://example.com/video.mp4
```

Not: Player ileride HTTP akışı (streaming) desteklerse bu yalnızca **oynatma** sorumluluğunda değerlendirilmelidir; dosyayı kalıcı olarak indirme yine Downloader'ın görevidir.

---

## 3. iPad1PDFReader'a Yönlendirilecek İşler

Aşağıdaki özellikler **iPad1PDFReader** sorumluluğundadır:

- PDF görüntüleme
- PDF sayfa navigasyonu
- PDF yakınlaştırma / sığdırma işlemleri
- PDF metin okuma modu
- PDF içeriğini okuma
- PDF yer imi / okuma konumu
- PDF'ye özel görüntüleme araçları

### Player davranışı

`.pdf` uzantılı dosyaları oynatmaya veya görüntülemeye çalışmaz.

iPad1PDFReader'a yönlendirilir.

Örnek:

```text
ipad1pdfreader://open?path=/var/mobile/Media/Documents/document.pdf
```

---

## 4. iPad1Player'ın Kendi Sorumlulukları

Aşağıdaki işler doğrudan **iPad1Player** kapsamındadır:

- MKV oynatma
- MP4 oynatma
- MOV oynatma
- M4V oynatma
- Video çözme / oynatma hattı
- H.264 donanım çözme entegrasyonu
- AAC / MP3 ses oynatma
- Harici SRT altyazı
- MKV içi gömülü altyazı
- SRT / ASS / SSA altyazı desteği
- Altyazı aç / kapat
- Altyazı track seçimi
- Ses track seçimi
- Altyazı gecikmesi
- Ses gecikmesi
- Oynat / duraklat
- İleri/geri sarma
- +/- 10 saniye ileri / geri
- Kaldığı yerden devam
- Oynatma hızı
- En-boy Sığdır / Doldur
- Tam ekran
- Ekran yönü
- Oynatma sırasında ekran uykusunu engelleme
- Codec uyumluluk / hata mesajları
- iPad 1 RAM / CPU sınırlarına uygun tampon yönetimi

---

## 5. Uygulamalar Arası URL Scheme Standardı

Uygulama ailesi içinde önerilen URL scheme adları:

```text
ipad1files://
ipad1downloader://
ipad1pdfreader://
ipad1player://
```

Önerilen temel çağrılar:

```text
ipad1player://open?path=<local_media_path>
ipad1pdfreader://open?path=<local_pdf_path>
ipad1downloader://download?url=<remote_url>
ipad1files://open?path=<local_path>
```

URL parametreleri uygulanırken yüzde kodlama yapılmalıdır.

---

## 6. Önerilen Ortak Router

Uygulama ailesi genelinde tekrar kullanılabilecek sınıf:

```text
IP1SuiteRouter
```

Önerilen hedef enum'u:

```objc
typedef enum {
    IP1SuiteTargetPlayer,
    IP1SuiteTargetFiles,
    IP1SuiteTargetDownloader,
    IP1SuiteTargetPDFReader,
    IP1SuiteTargetUnknown
} IP1SuiteTarget;
```

Önerilen API:

```objc
+ (IP1SuiteTarget)targetForPath:(NSString *)path;
+ (BOOL)openPath:(NSString *)path inTarget:(IP1SuiteTarget)target;
```

Amaç: Her uygulamanın kendi sorumluluk alanını koruması ve başka bir uygulamanın işini tekrar geliştirmemesi.

---

## 7. Geliştirme Öncesi Uygulama Ailesi Sorumluluk Filtresi

Her yeni özellik eklenmeden önce aşağıdaki sıra izlenmelidir:

1. Özellik medya oynatma ile doğrudan ilgili mi?
2. Dosya yönetimi ise iPad1Files'a yönlendir.
3. İndirme ise iPad1Downloader'a yönlendir.
4. PDF okuma/görüntüleme ise iPad1PDFReader'a yönlendir.
5. Ailedeki başka bir uygulamanın kapsamına giriyorsa Player'a ekleme.
6. Sadece Player'ın ana görevi ise iPad1Player içinde uygula.

---

## 8. Güncel Devir Durumu

### iPad1Files iş havuzu / devir
- Player içinden dosya gezme eklenmeyecek.
- Player içinden silme / taşıma / yeniden adlandırma eklenmeyecek.
- Player içinden ZIP / arşiv işlemi eklenmeyecek.
- Medya dosyasını bulma işi iPad1Files'ta kalacak.
- iPad1Files uygun medya türlerinde `ipad1player://open?...` çağrısı yapabilecek.

### iPad1Downloader iş havuzu / devir
- Player içine indirme yöneticisi eklenmeyecek.
- Kalıcı HTTP / FTP indirme Downloader'da kalacak.
- Downloader indirme tamamlandığında isteğe bağlı olarak Player'a devir yapabilecek.

### iPad1PDFReader iş havuzu / devir
- Player içine PDF önizleme / okuyucu eklenmeyecek.
- `.pdf` dosyaları PDFReader'a yönlendirilecek.
- PDF metin okuma / yer imi / okuma modu PDFReader'da kalacak.

---

## Sonuç

Uygulama ailesi görev ayrımı:

```text
Dosyayı bul / yönet      -> iPad1Files
Dosyayı indir            -> iPad1Downloader
PDF'yi oku               -> iPad1PDFReader
Video / sesi oynat       -> iPad1Player
```

Bu ayrım iPad 1'in düşük RAM ve CPU kaynakları açısından da önemlidir; her uygulama yalnızca kendi ana sorumluluğunu taşımalıdır.

---

## 9. alpha3 Rakip Analizi Sonrası Devir Güncellemesi

Player'a yalnızca oynatma ile doğrudan ilgili özellikler eklendi: en-boy ön ayarları, oynatma hızı, A-B tekrar, parlaklık/ses hareketleri, kontrol kilidi, çoklu harici SRT keşfi, altyazı kodlaması/boyutu/konumu ve medya bilgisi.

Rakiplerde bulunan aşağıdaki özellikler Player'a **bilerek eklenmedi**:

- Yerel dosya gezgini / yeniden adlandır / kopyala / taşı / sil / arşiv -> iPad1Files
- İndirme yöneticisi / HTTP-FTP kalıcı indirme -> iPad1Downloader
- PDF önizleme / okuyucu / yer imi -> iPad1PDFReader

MKV gömülü iz / ses gecikmesi özellikleri Player sorumluluğunda kalır ancak gerçek FFmpeg backend gelmeden kullanıcıya çalışıyormuş gibi sunulmaz.


## Alpha15 kod düzeyinde denetim

Player'ın şu uygulamaların sorumluluklarını üstlenmesini engellemek için `IP1SuiteScopeGate` eklendi:
- iPad1Files
- iPad1PDFReader
- iPad1Downloader

Gelecekteki Player özellik çalışmalarından önce bu kapıya bakılmalıdır.
