# iPad1Player sorumluluk kuralları

## iPad1Player'ın sorumlulukları

- Medya oynatma yaşam döngüsü.
- Medya çözme/demux altyapıları.
- Oynatma kontrolleri, ileri/geri sarma ve en-boy oranı.
- Oynatma konumu / devam durumu.
- Ses/video senkronizasyonu.
- Harici altyazı ayrıştırma, görüntüleme, aç/kapat ve zaman kaydırma.
- Gömülü medya izlerini bulma ve seçme.
- Desteklenmeyen codec/konteyner mesajları gibi oynatma tanılamaları.

## iPad1Player'ın sorumlu olmadıkları

Aşağıdakiler iPad1Files'a veya ailedeki başka bir özel uygulamaya aittir:

- Dizin gezinme.
- Dosya arama / sıralama / favoriler.
- Kopyala / taşı / sil / yeniden adlandır.
- Klasör oluşturma.
- ZIP/RAR/arşiv yönetimi.
- Genel metin/görsel/belge görüntüleme.
- İndirme yönetimi veya genel FTP dosya yönetimi.

## Uygulama ailesi kuralı

Bir özellik eklemeden önce, **medyanın kendisini oynatmak** için gerekli olup olmadığını sor. Değilse, yazmadan önce uygulama ailesi sorumluluk filtresini uygula.


## Alpha15 denetimi

`IP1SuiteScopeGate`, sorumluluk kuralını yalnızca dokümantasyonda değil kodda da kullanılabilir hale getirir.

Player'a ait anahtarlar: oynatma, demux/çözme, görüntüleyici, A/V senkronizasyonu, altyazılar, izler, bölümler ve tanılama.

Dosya işlemleri, belge/PDF okuma ve indirme yönetimi açıkça Player kapsamı dışındadır.


## Alpha16 açıklaması

MKV/H.264 oynatma açıkça Player'ın sorumluluğudur. Medya iPad1Files veya iPad1PDFReader'dan geldi diye oraya taşınmamalıdır.

O uygulamalar yerel yolu Player'a verir; demux/çözme/görüntüleme Player'ındır.


## Alpha17 uygulama ailesi incelemesi

AAC/MP3 çözme, PCM tamponlama ve AudioQueue ile oynatmanın hepsi oynatmanın doğal sorumluluklarıdır ve bu yüzden iPad1Player'da kalır.

iPad1Files, iPad1PDFReader veya iPad1Downloader'a karşılık gelen bir özellik eklenmedi.


## Alpha18 uygulama ailesi incelemesi

Uçtan uca demux -> AAC/MP3 çözme -> PCM -> AudioQueue -> saat döngüsü saf bir oynatma konusudur. Files, PDFReader veya Downloader'da paralel bir uygulamaya gerek yoktur.
