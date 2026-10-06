# Güncel Görevler

## Hemen yapılacak görev

### Gerçek A/V senkronizasyonunu yaz

Güncel oynatma, çözülen videoyu görüntüleyici sunabildiği anda gösteriyor.

Bu çalışan bir oynatma sağlıyor ama henüz zaman damgasına göre doğru senkronizasyon sağlamıyor.

Yapılacak iş:

1. Çözülen AVFrame'den video PTS'ini al.
2. Video zaman damgalarını akışın time_base'i ile dönüştür.
3. Ana saat olarak sesi kullan.
4. Karşılaştır:

       videoPTS - audioClock

5. Video erkense:
   - sunumu sınırlı bir aralıkta geciktir.

6. Video biraz geç kaldıysa:
   - hemen sun.

7. Video belirgin şekilde geç kaldıysa:
   - güvenli olduğu yerde çözülen kareyi at.

8. Kare kuyruklarını sınırlı tut.

9. Video zamanlaması yüzünden AudioQueue'yu asla bloklama.

## A/V senkronizasyonundan sonra

### EOF işleme

Konteyner sonunda (EOF):

- çözücüyü boşalt
- kuyruktaki video paketlerini boşalt
- geciktirilmiş H.264 karelerini temizle
- bekleyen PCM'i bitir
- "oynatma bitti" durumunu yay
- arayüzü geçerli bir durdurulmuş/tamamlanmış durumda bırak

### Duraklat / Devam

Doğrula:

- demux işçisi durma durumu
- video işçisi durma durumu
- paket kuyruğu durumu
- AudioQueue durumu
- saatin sürekliliği

### Uzun süreli test

Daha uzun bir H.264 480p MKV ile test et:

- 10 dakika
- 30 dakika
- tam film

İzlenecekler:

- bellek artışı
- ses tampon boşalmaları
- kare bozulması
- iş parçacığı kilitlenmesi
- kuyruk büyümesi
- A/V kayması

## Güncel oynatma aşaması için tamamlanma ölçütleri

FFmpeg oynatma yolu şunlar sağlanmadan kararlı sayılmamalı:

- temiz 480p görüntü
- kesintisiz ses
- tekrarlayan mikro donma yok
- kare bozulması yok
- sınırlı bellek
- kararlı A/V senkronizasyonu
- temiz EOF
- kararlı duraklat/devam
- uzun süreli cihaz testi
