# Alpha10 — iPad 1 Sıkılaştırma Aşaması

Bu sürüm bilinçli olarak ağır bir medya özelliği eklemez.

## Hedefler

- bellek baskısını azaltmak
- performans varsayılanlarını temkinli yapmak
- iOS bellek uyarılarındaki davranışı iyileştirmek
- tüm deneysel özellikleri test kapılarının arkasında tutmak

## Bellek bütçeleri

İlk düşük bellek profili:
- sıkıştırılmış video paketleri: en fazla 3 MB
- sıkıştırılmış ses paketleri: en fazla 768 KB
- metadata çalışma hedefi: 384 KB
- çözülmüş video kareleri: hedef en fazla 2
- altyazı yumuşak sınırı: 5000 satır

Bellek uyarısında:
- sıkıştırılmış video kuyruğu 1 MB'a doğru küçülür
- sıkıştırılmış ses kuyruğu 256 KB'a doğru küçülür
- gerekli olmayan altyazı yan dosyası listesi serbest bırakılır

## Güvenli oynatma hızı profili

Varsayılan olarak sunulan hızlar:
- 0.5x
- 0.75x
- 1.0x
- 1.25x
- 1.5x

2.0x deneysel kalır ve gerçek cihaz testi geçene kadar normal iPad 1 döngüsünün parçası değildir.

## Ayrıştırma güvenliği

Alpha9'un yalnız ayrıştırma politikası sıkılaştırıldı:
- metadata hedefi: 384 KB
- iz sınırı: 24
- bölüm sınırı: 128

## Reddedilen varsayılanlar

- birincil yol olarak yazılımsal 720p H.264
- HEVC
- AV1
- VP9
- 4K
- HDR
- güncel 10 bit hatlar

## Kural

Sektörle eşitlik hiçbir zaman iPad 1 kararlılığının önüne geçmez.
