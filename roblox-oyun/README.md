# KRALLIK SAVUNMASI — Roblox Studio oyunu

Bu proje Roblox Studio için hazırlanmış, oynanabilir bir üs savunma başlangıç oyunudur. GitHub Pages üzerinde çalışmaz; Roblox Studio'ya aktarılıp Roblox deneyimi olarak yayınlanır.

## Kurulum
1. Roblox Studio'yu aç ve **New > Baseplate** seç.
2. **View > Explorer** ve **View > Properties** panellerini aç.
3. **ServerScriptService** içine bir **Script** ekle, adını `KingdomServer` yap. `src/KingdomServer.server.lua` içeriğini bu Script'e yapıştır.
4. **StarterPlayer > StarterPlayerScripts** içine bir **LocalScript** ekle, adını `KingdomClient` yap. `src/KingdomClient.client.lua` içeriğini bu LocalScript'e yapıştır.
5. **Play** tuşuna bas. Harita, kale, düşmanlar ve arayüz otomatik oluşur.

## Oynanış
- WASD: hareket
- E tuşu / ekrandaki VUR: yakındaki düşmana kılıç saldırısı
- KULE veya DUVAR düğmesine basıp zeminde bir noktaya dokun/tıkla
- Bir okçu kulesinin yakınına gidip KULEYİ GELİŞTİR düğmesine bas (seviye başına artan altın gerekir; en fazla seviye 5)
- Goblin, zırhlı goblin ve ork dalgalarına karşı kristali koru
- Düşmanları yenerek altın kazan; kuleler otomatik ateş eder
- Mobilde ekrandaki savaş ve inşa düğmelerini kullan

Not: Bu bir Roblox Studio proje kodudur; Roblox hesabında yayınlama işlemi Roblox Studio içinden yapılır.


## Bu sürümde eklenenler
- Üç farklı düşman sınıfı: goblin, zırhlı goblin ve ork; farklı can, hız, hasar ve ödüller.
- Okçu kuleleri için yakından yükseltme: hasar ve menzil seviye başına artar; en yüksek seviye 5.
- İstemci isteklerinde sunucu tarafı eylem aralığı kontrolü, bina türü/konum/mesafe ve altın doğrulaması.
- Dokunmatik ekranda bina yerleştirme ve daha kompakt savaş düğmeleri.
