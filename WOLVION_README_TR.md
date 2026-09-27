# Wolvion Browser — iPhone kaynak kodu

Bu çalışma [BrownBear](https://github.com/DudeAint/brownbear) açık kaynak projesinin
27 Eylül 2026 tarihinde alınmış MIT lisanslı bir kopyasıdır. Özgün lisans ve proje adı kaynak
dosyalarında korunmuştur. iPhone ana ekranında görünen ad **Wolvion Browser** olarak ayarlanmıştır.

## Bu kopyada yapılan değişiklik

- Chrome, Edge, Firefox mağazası, bağlantı, öneriler ve yerel CRX/ZIP yüklemeleri, aynı zorunlu
  onay kapısından geçer.
- İndirilen paketin `manifest.json` dosyasındaki gerekli API izinleri, site erişimi,
  sayfada çalışacak betiklerin eşleşmeleri ve sonradan istenebilen izinler kurulmadan önce görünür.
- Kullanıcı iptal ederse uzantı yüklenmez. Yeniden yükleme iptal edilirse eskisi korunur.
- Mevcut BrownBear site korumaları ve uzantı motoru yerinde kalır. Kurulum ekranı kötü amaçlı kod
  taraması ya da uzantının güvenilirliğine ilişkin garanti değildir.

## Durum

Kaynak kodu hazırdır; bu ortam Linux olduğu için iOS uygulaması derlenmedi veya iPhone üzerinde
çalıştırılmadı. Bir IPA ya da TestFlight dağıtımı değildir. Tüm Chrome uzantıları veya tüm
güvenlik uzantılarıyla uyumluluk iddia edilmez. BrownBear, Apple WebKit üzerinde kendi uyumluluk
katmanını kullanır; bazı Chrome API'leri eksik veya farklı davranabilir.

## Mac ile çalıştırma

1. Xcode 15 veya üzerini ve XcodeGen'i kurun (`brew install xcodegen`).
2. Bu klasörde `xcodegen generate` komutunu çalıştırın.
3. `BrownBear.xcodeproj` dosyasını Xcode ile açın; **BrownBear** şemasını ve iPhone'unuzu seçin.
4. Signing & Capabilities bölümünde kendi Apple geliştirme takımınızı seçin. `com.wolvion.browser`
   tanımlayıcısı hesabınızda kullanımdaysa `project.yml` içindeki `PRODUCT_BUNDLE_IDENTIFIER`
   değerini değiştirip yeniden `xcodegen generate` çalıştırın.
5. Önce bir iOS simülatöründe derleyin ve testleri çalıştırın; ardından cihazda deneyin.

Kaynak projenin ayrıntılı derleme yönergeleri: `docs/BUILDING.md`. Üçüncü taraf bağımlılıklar
Xcode tarafından indirilecektir. TestFlight yayını için ayrıca Apple geliştirici hesabı,
imzalama ve App Store Connect kurulumu gerekir.

## GitHub bağlantısı ve iPhone ana ekranı

GitHub bağlantısı projenin kodunu açar. Safari'de **Ana Ekrana Ekle** ile bu bağlantının
kısayolunu oluşturmak, iOS tarayıcı uygulamasını kurmaz; Chrome uzantıları bu kısayolda
çalışmaz. Gerçek tarayıcı simgesinin ana ekranda görünmesi için uygulama Xcode'da derlenip
bir Apple hesabıyla imzalanarak iPhone'a yüklenmelidir. Geliştirici hesabıyla TestFlight
dağıtımı da hazırlanabilir.

Depodaki `.github/workflows/ci.yml` GitHub üzerinde iOS simülatörü derlemesi ve testleri
çalıştırır; CI çıktısı imzalı iPhone yükleme paketi değildir. Kaynak kodu GitHub'a aktarılınca
önce bu testlerin sonucuna bakmak gerekir.

## Conso AI Usage Tracker bulguları

Paylaştığınız 0.1.4 CRX paketinin manifestinde `storage`, `identity`, `scripting` izinleri;
`conso.xyz` alanlarına zorunlu erişim ve ChatGPT, Claude, Gemini, Perplexity alanlarına
isteğe bağlı erişim var. Paket Google girişi sırasında `identity.getRedirectURL` ve
`identity.launchWebAuthFlow` kullanıyor. BrownBear'ın kodunda bu API'ler var, ancak iPhone'da
bu CRX'in açılması, veri toplaması veya giriş yapması test edilmedi.

Önemli uyumluluk riski: BrownBear mağazadan yüklenen eklentiye yeni bir yerel uzantı kimliği
veriyor. Conso'nun Google OAuth istemcisi özgün Chrome uzantısı kimliğiyle ilişkili bir yönlendirme
adresi bekliyorsa Google girişi başarısız olabilir. Bunu doğrulamak için gerçek cihaz testi ve
gerekirse uzantı geliştiricisiyle kimlik/yönlendirme desteği gerekir.

## Kaynak ve lisans

BrownBear, MIT lisansı altındadır. Lisansın tam metni `LICENSE` dosyasında; kaynak proje
teşekkürleri ve üçüncü taraf bildirimleri `THIRD_PARTY_NOTICES.md` dosyasındadır.
