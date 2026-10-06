# Oynatma Motoru Sözleşmesi — alpha8

## P0 yaşam döngüsü

FFmpeg destekli motorun artık açık yaşam döngüsü metotları var:

1. `open`
2. `play`
3. `pause`
4. `seek`
5. `close`

Adaptörün sorumlulukları:
- sınırlı video paket kuyruğu
- sınırlı ses paket kuyruğu
- oynatma saati
- iz listesi
- bölüm listesi
- medya bilgisi

Kaynak FFmpeg olmadan da derlenebilir kalır.

## A/V saati

Tercih edilen ana saat:
1. ses varsa ses saati
2. ses yoksa video saati
3. yalnızca istisnai durumlarda harici saat

`IP1PlaybackClock` zaman durumunu merkezileştirir.

## Kare zamanlaması

`IP1FramePolicy` şunları döndürür:
- Render (görüntüle)
- Wait (bekle)
- Drop (at)

Politika:
- kare çok erken -> kısa bekle
- kare zamanında -> görüntüle
- kare çok geç -> at

Bu, iPad 1'de gecikmeyi ve bellek büyümesini önler.

Cihaz testi için önerilen başlangıç eşikleri:
- erken toleransı: ~20 ms
- geç toleransı: ~80–120 ms

Bunlar test değerleridir, garanti edilmiş nihai sabitler değildir.

## İleri sarma

İleri sarma şunları yapmalıdır:
1. demux/çözme işini duraklat
2. sıkıştırılmış paket kuyruklarını temizle
3. çözülmüş kare/ses tamponlarını temizle
4. demux'u anahtar kareye konumlandır
5. oynatma saatlerini sıfırla
6. çözmeye devam et

Güncel adaptör kuyruk temizleme sözleşmesini zaten sunuyor.

## İz değiştirme

Adaptör sözleşmesi şunları destekler:
- ses akışını akış numarasıyla seçme
- altyazı akışını akış numarasıyla seçme
- akış numarası `-1` ile altyazıyı kapatma

Gerçek codec temizleme/yeniden açma davranışı yalnızca FFmpeg bağlandığında uygulanır.

## iPad 1 sınırları

Asla:
- sınırsız kuyruk kullanma
- medya dosyasının tamamını önbelleğe alma
- birincil yol olarak yazılımsal 720p H.264 kullanma
- gerçek cihaz doğrulaması olmadan eski donanım H.264 iddia etme
