# Wolvion Browser

<div align="center">
  <img src="BrownBear/Resources/Assets.xcassets/AppIcon.appiconset/icon-light.png" width="180" alt="Sarı zeminde kedi simgeli Wolvion Browser" />
</div>

iPhone için geliştirilen, WebKit tabanlı açık kaynak tarayıcı. Bu proje [BrownBear](https://github.com/DudeAint/brownbear) kaynak kodu üzerine kurulmuştur; MIT lisansı ve özgün proje bilgisi korunur. Ana ekran simgesi ve uygulama adı **Wolvion Browser** olarak düzenlenmiştir.

## Şu anki durum

- Kaynak kodu ve iOS simülatör testleri GitHub'dadır: [CI sonuçları](https://github.com/Tryamaha/wolvion-browser/actions/workflows/ci.yml).
- İmzalanmış iPhone uygulaması, IPA veya TestFlight daveti henüz yok. GitHub bağlantısı kodu gösterir; Safari'de Ana Ekrana Ekle uygulamayı kurmaz.
- Gerçek iPhone'da uzantı kurulumu ve özellikle Conso AI Usage Tracker'ın Google girişi henüz doğrulanmadı.

## Özellikler

- Çok sekmeli iOS tarayıcı, arama, yer imleri ve geçmiş.
- Kullanıcı betikleri ve BrownBear'ın Chrome/Firefox uzantıları için WebKit uyumluluk katmanı.
- CRX/ZIP veya mağaza bağlantısından uzantı yüklemeden önce gerekli API ve site izinlerinin gösterilmesi; iptalde yükleme yapılmaması.
- Yeni sekmede Wolvion simgesi; uygulama simgesinde kullanıcı tarafından seçilen sarı zeminli kedi görseli.

Uzantıların her biri farklı API'ler kullanır. Derlemenin başarılı olması, belirli bir Chrome uzantısının iPhone'da eksiksiz çalıştığını göstermez. Teknik ayrıntılar için [uzantı belgelerine](docs/WEB_EXTENSIONS.md) bakın.

## Mac ile derleme

1. Xcode 15 veya üzerini ve XcodeGen'i kurun.
2. Depoyu indirip klasörde `xcodegen generate` çalıştırın.
3. Oluşan `BrownBear.xcodeproj` dosyasını Xcode'da açın. **BrownBear** şemasını seçin; bu geliştirme içi ad, ana ekranda görünen **Wolvion Browser** adından farklıdır.
4. Signing & Capabilities bölümünde Apple geliştirme takımınızı seçin. Gerekirse `project.yml` içindeki `com.wolvion.browser` paket kimliğini değiştirip projeyi yeniden oluşturun.
5. Önce simülatörde, ardından iPhone'da deneyin.

Ayrıntılar: [Türkçe proje notları](WOLVION_README_TR.md) ve [derleme rehberi](docs/BUILDING.md).

## Kaynak ve lisans

Bu depo BrownBear'dan türetilmiştir. Özgün yazar bilgisi ve tam MIT lisansı [LICENSE](LICENSE) dosyasındadır; diğer bağımlılıklar için [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) dosyasına bakın. Wolvion değişiklikleri arasında uzantı yükleme izni ekranı ve yeni görsel kimlik bulunur.
