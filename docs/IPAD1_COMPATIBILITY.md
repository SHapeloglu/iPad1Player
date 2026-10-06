# iPad 1 Uyumluluk Kapısı

Hedef:
- iPad 1 / A4
- iOS 5.1.1
- armv7
- ~256 MB RAM
- Objective-C / UIKit
- non-ARC/MRC
- Theos / eski iPhoneOS 6.1 SDK

Her yeni özellik tamamlanmış sayılmadan önce şu kontrollerden geçmelidir:

1. API iOS 5.1.1'de mevcut.
2. armv7 derlemesi başarılı.
3. MRC sahipliği/yaşam döngüsü güvenli.
4. Tepe bellek kullanımı sınırlı.
5. Sürekli CPU maliyeti kabul edilebilir.
6. Çözme/görüntüleme döngüsüne gereksiz iş eklemiyor.
7. Kare başına bellek ayırmalar en aza indirilmiş.
8. Disk G/Ç en aza indirilmiş.
9. Gerçek iPad 1 test durumu kaydedilmiş.
10. Daha hafif bir uygulama düşünülmüş.

## Durum anlamları

### IPAD1_SAFE
Mimari/API/maliyet iPad 1'e uygun ve olağan dışı cihaza özel performans varsayımları gerektirmiyor.

### IPAD1_TEST_REQUIRED
Özelliğe kaynakta izin verilir ama gerçek cihazda test edilmeden kanıtlanmış denemez.

### IPAD1_REJECTED
Özellik iPad 1 hedefi için bilinçli olarak dışarıda bırakılmıştır.

## Güncel matris

| Özellik | Durum |
|---|---|
| Harici SRT | IPAD1_SAFE |
| Altyazı gecikmesi/boyutu/konumu | IPAD1_SAFE |
| Kaldığı yerden devam | IPAD1_SAFE |
| Bölüm modeli | IPAD1_SAFE |
| Uyku zamanlayıcısı | IPAD1_SAFE |
| Hareketle sarma | IPAD1_SAFE |
| MKV demux | IPAD1_SAFE |
| Sınırlı paket kuyrukları | IPAD1_SAFE |
| 2.0x oynatma | IPAD1_TEST_REQUIRED |
| Ses düzeyi hareketi | IPAD1_TEST_REQUIRED |
| Temel ASS/SSA | IPAD1_TEST_REQUIRED |
| AC3/E-AC3 | IPAD1_TEST_REQUIRED |
| 720p eski donanım H.264 | IPAD1_TEST_REQUIRED |
| 480p yazılımsal H.264 | IPAD1_TEST_REQUIRED |
| Birincil yol olarak 720p yazılımsal H.264 | IPAD1_REJECTED |
| HEVC/H.265 | IPAD1_REJECTED |
| AV1 | IPAD1_REJECTED |
| VP9 | IPAD1_REJECTED |
| 4K | IPAD1_REJECTED |
| HDR | IPAD1_REJECTED |
| Güncel 10 bit video hattı | IPAD1_REJECTED |

## alpha7 optimizasyonları

### Altyazı
Önceki davranış her 100 ms'de tüm SRT satırlarını tarayabiliyordu.

Yeni davranış:
- normal oynatma: yalnızca güncel/sonraki satıra bakar.
- sarma/atlama: ikili arama.

### Kaldığı yerden devam
Önceki:
- her 5 saniyede kaydetme
- açık synchronize

Yeni:
- her 30 saniyede kaydetme
- duraklatma/durdurma/arka plan/kapanışta kaydetme
- zorunlu synchronize yok

### Zamanlayıcılar
Altyazı, devam ve uyku zamanlayıcılarının hepsi tek bir temizlik yolundan geçer.

### Parlaklık
Player orijinal parlaklığı saklar ve hareket parlaklığı değiştirdiyse oynatmadan çıkarken geri yükler.

### Ses düzeyi
Hareket artık `applicationMusicPlayer`'ı değil film oynatma nesnesini kontrol eder. Bu `IPAD1_TEST_REQUIRED` olarak kalır.

## Donanım çözme kuralı

Gerçek bir iPad 1 testi kanıtlamadan eski H.264 donanım çözme desteğini asla tanımlama veya duyurma.

iOS 5.1.1 için güncel VideoToolbox varsayımları kabul edilmez.


## Alpha9 yalnız ayrıştırma kararları

| Özellik | Durum |
|---|---|
| Yalnız ayrıştıran FFmpeg metadata | IPAD1_TEST_REQUIRED |
| İz listeleme | IPAD1_TEST_REQUIRED |
| Bölüm çıkarma | IPAD1_TEST_REQUIRED |
| Ayrıntılı medya bilgisi çıkarma | IPAD1_TEST_REQUIRED |
| Ayrıştırma sırasında paket tamponlama | IPAD1_REJECTED |
| Ayrıştırma sırasında kare çözme | IPAD1_REJECTED |

Ayrıştırıcı FFmpeg bağlamlarını metadata çıkarıldıktan hemen sonra serbest bırakmalıdır.


## Alpha10 sıkılaştırma kararları

| Özellik | Durum |
|---|---|
| Bellek uyarısında temizleme | IPAD1_SAFE |
| Temkinli bellek bütçeleri | IPAD1_SAFE |
| 1.5x'e kadar güvenli hız profili | IPAD1_SAFE |
| 2.0x oynatma | IPAD1_TEST_REQUIRED |
| Yalnız ayrıştıran FFmpeg entegrasyonu | IPAD1_TEST_REQUIRED |

Alpha10 kararlılığı özellik sayısının önünde tutar.


## Alpha11 ayrıştırma çalışma zamanı kapısı

| Özellik | Durum |
|---|---|
| Metadata sonrası ayrıştırma bağlamını hemen kapatma | IPAD1_SAFE |
| Metadata/iz/bölüm savunmacı sınırları | IPAD1_SAFE |
| Gerçek libavformat ayrıştırma | IPAD1_TEST_REQUIRED |
| Akış listeleme | IPAD1_TEST_REQUIRED |
| Bölüm çıkarma | IPAD1_TEST_REQUIRED |
| Ayrıntılı medya bilgisi çıkarma | IPAD1_TEST_REQUIRED |

alpha11'de çözme yeteneği değişikliği yok.


## Alpha12 entegrasyon öncesi kapı

| Özellik | Durum |
|---|---|
| FFmpeg derleme yeteneği kontrolü | IPAD1_SAFE |
| Ayrıştırma sonucu doğrulayıcı | IPAD1_SAFE |
| Ayrıştırma geri dönüş politikası | IPAD1_SAFE |
| Gerçek armv7 FFmpeg bağlama | IPAD1_TEST_REQUIRED |
| FFmpeg altyapısının sürümde açılması | IPAD1_TEST_REQUIRED |

Çözme/görüntüleme değişmeden kalır.


## Alpha13 sağlamlık kararları

| Özellik | Durum |
|---|---|
| Medya yolu/dosya ön kontrolü | IPAD1_SAFE |
| Bozuk metadata makullük doğrulaması | IPAD1_SAFE |
| 10 döngülük ayrıştır/kapat yük düzeneği | IPAD1_SAFE |
| En fazla 25 döngülük test düzeneği | IPAD1_SAFE |
| Gerçek bellek sızıntısı kararı | IPAD1_TEST_REQUIRED |

Hiçbir codec/çözme yeteneği açılmadı.


## Alpha14 gerçek ayrıştırma uygulaması

| Özellik | Durum |
|---|---|
| libavformat ayrıştırma kaynak uygulaması | IPAD1_TEST_REQUIRED |
| Akış listeleme uygulaması | IPAD1_TEST_REQUIRED |
| Bölüm çıkarma uygulaması | IPAD1_TEST_REQUIRED |
| Medya bilgisi eşleme uygulaması | IPAD1_TEST_REQUIRED |
| Ayrıştırma sırasında çözücü açma | IPAD1_REJECTED |
| Ayrıştırma sırasında paket tamponlama | IPAD1_REJECTED |

Bunlar ancak armv7 derlemesi ve gerçek iPad 1 çalışma zamanı testlerinden sonra SAFE'e geçer.


## Alpha15 yalnız Player'a ait uyumluluk kararları

| Özellik | Durum |
|---|---|
| Kod düzeyinde uygulama ailesi kapsam kapısı | IPAD1_SAFE |
| 256 KB sınırlı PCM halka tampon | IPAD1_SAFE |
| Yalnızca seçili ses izini çözme politikası | IPAD1_SAFE |
| Stereo/44.1 kHz temkinli çıkış profili | IPAD1_SAFE |
| Gerçek AAC/MP3 çözme | IPAD1_TEST_REQUIRED |
| 480p H.264 yazılımsal çözme | IPAD1_TEST_REQUIRED |
| 720p yazılımsal H.264 birincil yol | IPAD1_REJECTED |
| Player'da PDF/dosya yöneticisi/indirme özellikleri | IPAD1_REJECTED |


## Alpha16 MKV/H.264 politikası

| Özellik | Durum |
|---|---|
| MKV demux | IPAD1_SAFE mimari / çalışma zamanı testi gerekli |
| H.264 360p yazılımsal oynatma | IPAD1_TEST_REQUIRED |
| H.264 480p yazılımsal oynatma | IPAD1_TEST_REQUIRED |
| H.264 720p yazılımsal birincil yol | IPAD1_REJECTED |
| H.264 720p doğrulanmış eski donanım/hibrit | IPAD1_TEST_REQUIRED |
| 720p üstü yazılımsal oynatma | IPAD1_REJECTED |

MKV/H.264 oynatma açıkça iPad1Player kapsamındadır.


## Alpha17 ses çalışma zamanı

| Özellik | Durum |
|---|---|
| AudioQueue 3x16 KB çıkış tamponları | IPAD1_TEST_REQUIRED |
| 256 KB PCM halka tampon | IPAD1_SAFE |
| AAC çözücü kaynağı | IPAD1_TEST_REQUIRED |
| MP3 çözücü kaynağı | IPAD1_TEST_REQUIRED |
| Paketlenmiş S16 PCM yolu | IPAD1_TEST_REQUIRED |
| swresample ile S16 dışı dönüşüm | NOT ENABLED (açılmadı) |
| AC3/E-AC3 çözme | NOT ENABLED (açılmadı) |

alpha17'deki tüm işler iPad1Player kapsamındadır.


## Alpha18 ses döngüsü

| Özellik | Durum |
|---|---|
| Seçili akış av_read_frame döngüsü | IPAD1_TEST_REQUIRED |
| Tek demux iş parçacığı | IPAD1_SAFE mimari |
| 64 KB çözme karalama tamponu | IPAD1_SAFE |
| %75'te PCM geri basıncı | IPAD1_SAFE |
| Kabul edilen PCM baytlarından ses saati | IPAD1_TEST_REQUIRED |
| Kesintisiz AAC/MP3 oynatma | IPAD1_TEST_REQUIRED |
| Bu aşamada video çözme | NOT ENABLED (açılmadı) |

Alpha18'deki tüm değişiklikler iPad1Player sorumluluğu içinde kalır.
