# KRALLIK SAVUNMASI — Roblox Studio oyunu

Bu proje Roblox Studio için hazırlanmış, oynanabilir bir üs savunma başlangıç oyunudur. GitHub Pages üzerinde çalışmaz; Roblox Studio'ya aktarılıp Roblox deneyimi olarak yayınlanır.

## Kurulum
1. Roblox Studio'yu aç ve **New > Baseplate** seç.
2. **View > Explorer** ve **View > Properties** panellerini aç.
3. **ServerScriptService** içine bir **Script** ekle, adını \`KingdomServer\` yap. \`src/KingdomServer.server.lua\` içeriğini bu Script'e yapıştır.
4. **StarterPlayer > StarterPlayerScripts** içine bir **LocalScript** ekle, adını \`KingdomClient\` yap. \`src/KingdomClient.client.lua\` içeriğini bu LocalScript'e yapıştır.
5. **Play** tuşuna bas. Harita, kale, düşmanlar ve arayüz otomatik oluşur.

## Oynanış
- WASD: hareket
- E tuşu veya ekrandaki **VUR**: yakındaki düşmana saldırı
- **KULE**, **DUVAR** veya **MUHAFIZ** düğmesine basıp zeminde bir noktaya dokun/tıkla
- Bir okçu kulesi ya da muhafızın yakınına gidip **SAVUNMAYI GELİŞTİR** düğmesine bas
- Her savunma en fazla 5. seviyeye yükseltilebilir; geliştirme maliyeti seviye başına artar
- Goblin, zırhlı goblin ve ork dalgalarına karşı kristali koru
- Her 5. dalganın sonunda güçlü **Ork Şefi** çıkar
- Düşmanları yenerek takım altını kazan; kuleler ve muhafızlar otomatik saldırır

## Bu sürümdeki geliştirmeler
- Üç temel düşman sınıfına ek olarak her 5. dalgada bir Ork Şefi boss'u.
- Yeni yerleştirilebilir muhafız birimi; yakındaki düşmanlara otomatik saldırır.
- Kule ve muhafız yükseltmeleri hasarı ve menzili artırır (en fazla seviye 5).
- Mobil dokunma konumundan ışın göndererek bina yerleştirme ve telefon/tablet/masaüstüne göre yeniden düzenlenen HUD.
- Sunucu tarafında bina türü, koordinat, arena sınırı, oyuncu mesafesi, altın, çakışma, eylem ve saldırı bekleme süresi kontrolleri.
- Kale gövdesinin çarpışması kapatılarak düşmanların kristale ulaşması sağlandı.

## Studio'da test kontrol listesi
1. **View > Output** penceresini aç; kırmızı hata olmadığını kontrol et.
2. **Test > Start** ile iki oyunculu test başlat; ortak altın ödülünü ve dalga bilgisini kontrol et.
3. Kule, duvar ve muhafızın yalnızca geçerli alana kurulabildiğini dene.
4. Bir kule/muhafızın yanına gidip yükselt; altının azaldığını ve savunmanın güçlendiğini kontrol et.
5. Mobil cihazda veya **Test > Device Emulator** ile dokunmatik yerleştirme ve HUD ölçeklemesini dene.
6. **File > Publish to Roblox** ile deneyimi hesabına yayınla; ardından **Game Settings > Permissions** ve erişim ayarlarını kontrol et.

Not: Bu dosyalar Roblox Studio proje kodudur. Bu güncellemede Roblox Studio çalışma zamanı açılamadığı için oyun burada gerçekten çalıştırılmadı ve Roblox'a yayınlanmadı. Yayınlamadan önce yukarıdaki testleri Studio'da yap.
