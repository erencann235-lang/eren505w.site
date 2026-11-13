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
- Sol tık / Ekrandaki VUR: yakındaki düşmana kılıç saldırısı
- Arayüzden OKÇU KULESİ veya DUVAR seçip haritadaki yeşil alana tıkla
- Düşman dalgalarına karşı kalenin KRİSTALİNİ koru
- Düşmanları yenerek altın kazan, savunmanı güçlendir
- Her dalgada düşmanlar güçlenir

Not: Bu bir Roblox Studio proje kodudur; Roblox hesabında yayınlama işlemi Roblox Studio içinden yapılır.
