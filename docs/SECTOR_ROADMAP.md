# Sektör Yol Haritası

Bu yol haritası, sektör karşılaştırması bulgularını uygulama ailesi sorumluluk sınırlarını koruyarak iPad1Player önceliklerine dönüştürür.

## P0 — evrensel oynatıcı çekirdeği

Uygulamaya gerçek bir MKV oynatıcı demeden önce gerekenler:
- MKV için FFmpeg demux.
- H.264/AVC video.
- AAC ve MP3 ses.
- A/V senkronizasyonu.
- sınırlı, düşük bellekli paket kuyrukları.
- kuyruk temizlemeli ileri sarma.
- cihazda 480p ve 720p testleri.
- yazılımsal çözmeye geri dönüş.
- eski donanım H.264 yalnızca iPad 1'de doğrulanırsa.

## P1 — iz/altyazı eşitliği

- birden fazla ses izi.
- gömülü SRT.
- ASS/SSA.
- gömülü altyazı seçimi.
- ses gecikmesi.
- altyazı gecikmesi.
- dil/başlık metadata'sı.
- bölüm desteği.
- ayrıntılı medya bilgisi.

## P2 — işe yarar eski format genişlemesi

Yalnızca P0/P1 kararlı olduktan sonra:
- AVI konteyneri.
- MPEG-4 Part 2 / Xvid.
- AC3.
- E-AC3.
- daha zengin medya bilgisi: codec, fps, bit hızı, boyutlar, örnekleme hızı, kanallar.
- 2.0x'e kadar oynatma hızı.
- uyku zamanlayıcısı.

## P3 — isteğe bağlı, performansa bağlı

- ses yükseltme.
- deinterlace.
- son işleme.

iPad 1'in ısınmasına, bellek baskısına veya oynatma kararlılığına zarar verirlerse bunları ekleme.

## iPad 1 için açıkça hedef dışı

- HEVC/H.265
- AV1
- VP9
- 4K
- HDR
- güncel 10 bit hatlar

## Uygulama ailesi sahipliği

- dosya yönetimi -> iPad1Files
- indirmeler -> iPad1Downloader
- PDF -> iPad1PDFReader
- medya oynatma -> iPad1Player


## Uyumluluk kapısı

Sektörle eşitlik hiçbir zaman iPad 1 hedefinin önüne geçmez.

Yazmadan veya sürüm çıkmadan önce her özellik `docs/IPAD1_COMPATIBILITY.md`'ye göre kontrol edilmelidir. `IPAD1_TEST_REQUIRED` işaretli özellikler cihazda iPad 1 testi gerektirir; `IPAD1_REJECTED` özellikler yazılmaz.


## alpha8 motor sözleşmesi

P0 mimarisi artık şunları içeriyor:
- oynatma ana saati modeli
- kare görüntüle/bekle/at politikası
- açık adaptör yaşam döngüsü
- iz değiştirme sözleşmesi

Bu yalnızca mimari hazırlıktır. Gerçek FFmpeg demux/çözme ve cihazda oynatma testleri başarılı olmadan P0 tamamlanmış sayılmaz.
