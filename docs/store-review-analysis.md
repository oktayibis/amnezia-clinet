# AWG Connect — App Store & Mac App Store İnceleme Hazırlık Raporu

**Tarih:** 12 Eylül 2026  
**Uygulama Adı:** AWG Connect (Eski Kod Adı: Amnezia Client)  
**Paket Kimliği (Bundle Identifier):** `com.oktayibis.awgconnect`  
**Geliştirici:** Oktay İbiş  
**Hedef Platformlar:** iOS 16.0+ (iPhone), macOS 14.0+ (Apple Silicon & Intel)

---

## 1. Yönetici Özeti (Executive Summary)

Bu rapor, iOS ve macOS platformları için geliştirilen **AWG Connect** istemcisinin Apple App Store ve Mac App Store inceleme süreçlerine (App Review) hazırlanması, Apple App Store Review Guidelines (özellikle **Guideline 5.4 - VPN Apps**, **Guideline 2.1 - App Completeness**, **Guideline 2.3 - Accurate Metadata**, **Guideline 5.1.1/5.1.2 - Data Privacy**) gereksinimlerinin karşılanması ve tespit edilen tüm teknik/idari eksikliklerin giderilmesi amacıyla hazırlanmıştır.

### Mevcut Durum ve Gönderim Uygunluğu:
> [!IMPORTANT]
> **Önemli Sonuç:** Uygulama, bu hazırlık turu sonrasında **UI, lisans, gizlilik politikası, Privacy Manifest, App Sandbox, Entitlements ve Apple Guidelines 5.4 uyumluluğu** açısından App Store standartlarına getirilmiştir.  
> Ancak **gerçek AmneziaWG/WireGuard C-Go tünel motoru** (`amneziawg-apple` / `wireguard-go`) `PacketTunnelProvider` içine entegre edilene kadar **canlı mağaza incelemesine (Production Submission) GÖNDERİLMEMELİDİR**. Şu anki `PacketTunnelProvider`, sistem IP ve DNS ayarlarını oluşturmakta fakat şifrelenmiş tünel üzerinden gerçek veri akışı (packet flow) yapmamaktadır; bu durum Apple test ekibinin bağlantı sırasında internet trafiğinin akmadığını görmesiyle **Guideline 2.1 (App Completeness)** gerekçesiyle doğrudan ret almasına yol açar.

---

## 2. Bulgular ve Düzeltmeler Tablosu (19 Madde)

Yapılan kapsamlı kod ve mimari denetiminde tespit edilen 19 bulgu ve alınan aksiyonlar:

| No | Kategori | Bulgusu Yapılan Konu | Apple Kılavuzu | Önem | Durum |
|:---|:---|:---|:---|:---:|:---:|
| **B1** | Marka / İsimlendirme | "Amnezia" tescilli marka çakışması riski. | Guideline 2.3.8, 4.1 | **KRİTİK** | **DÜZELTİLDİ** (Görünen ad `AWG Connect`, paket kimliği `com.oktayibis.awgconnect` yapıldı) |
| **B2** | İşlevsellik | Release derlemesinde mock/simüle tünelin çalışması ve kullanıcıya sunulması. | Guideline 2.1 | **KRİTİK** | **DÜZELTİLDİ** (Simülasyon Release'den çıkarıldı, `#if DEBUG` ve simülatöre bağlandı) |
| **B3** | macOS Mimarisi | macOS için Network Extension (`AmneziaTunnelMac`) eksikliği. | Teknik / Guideline 2.1 | **KRİTİK** | **DÜZELTİLDİ** (`AmneziaTunnelMac` target'ı ve entitlements oluşturuldu) |
| **B4** | macOS Güvenlik | macOS App Sandbox ve Packet Tunnel Provider entitlements eksikliği. | Guideline 2.4.5 | **KRİTİK** | **DÜZELTİLDİ** (App Sandbox, Network Client/Server, Packet Tunnel yetkileri tanımlandı) |
| **B5** | Yanıltıcı UI | macOS'ta sahte rastgele ping (`Int.random`) ve boş 0 B/s veri sayaçları. | Guideline 2.3 | **YÜKSEK** | **DÜZELTİLDİ** (Sahte ping tamamen silindi, sayaçlar veri yokken gizlendi) |
| **B6** | Bağlantısız Ayarlar | Kill Switch ve DNS sağlayıcı seçeneklerinin tünele aktarılmaması. | Guideline 2.1 | **YÜKSEK** | **DÜZELTİLDİ** (`includeAllNetworks` ve `dnsOverride` `startTunnel`'a bağlandı) |
| **B7** | Pano Gizliliği | Sayfa açılışında (`.onAppear`) ve timer ile izinsiz pano (clipboard) okunması. | Guideline 5.1.2 | **YÜKSEK** | **DÜZELTİLDİ** (Otomatik okuma kaldırıldı; net butonla kullanıcı tetiklemeli yapıldı) |
| **B8** | VPN Gizlilik Bildirimi | İlk açılışta Guideline 5.4 gereği VPN veri gizliliği onay ekranının olmaması. | Guideline 5.4.1 | **YÜKSEK** | **DÜZELTİLDİ** (iOS ve macOS'a açılışta `PrivacyNoticeView` eklendi) |
| **B9** | Gizlilik Politikası | Projede yasal Gizlilik Politikası belgesinin bulunmaması. | Guideline 5.1.1 | **YÜKSEK** | **DÜZELTİLDİ** (`PRIVACY.md` oluşturuldu ve ayarlar menüsünden bağlandı) |
| **B10** | Gizlilik Beyanı | Apple 2024 zorunluluğu olan `PrivacyInfo.xcprivacy` manifestlerinin eksikliği. | Apple Privacy Req | **YÜKSEK** | **DÜZELTİLDİ** (iOS, macOS ve Tunnel için manifestler eklendi ve doğrulandı) |
| **B11** | Lisans ve Yasal | Projede açık kaynak lisans dosyasının bulunmaması. | Yasal Gereksinim | **ORTA** | **DÜZELTİLDİ** (2026 Oktay İbiş adına MIT `LICENSE` dosyası eklendi) |
| **B12** | Hata Mesajları | "paid Apple Developer Program" gibi incelemeciyi yanıltıcı hata metinleri. | Guideline 2.3 | **ORTA** | **DÜZELTİLDİ** (Kullanıcı dostu, nötr izin rehberliği metinleriyle değiştirildi) |
| **B13** | macOS Özelliği | macOS "Connect on Launch" ayarının uygulama açılışında çalışmaması. | Guideline 2.1 | **ORTA** | **DÜZELTİLDİ** (`AmneziaMacApp` açılışında `onAppear` ile tetiklendi) |
| **B14** | Sürüm Metinleri | Ayarlar sayfalarında statik "v1.0.0" metinleri bulunması. | Guideline 2.3 | **DÜŞÜK** | **DÜZELTİLDİ** (`Bundle.main.infoDictionary` üzerinden dinamik yapıldı) |
| **B15** | Şifreleme Beyanı | `ITSAppUsesNonExemptEncryption` anahtarının `Info.plist`'te eksik olması. | Export Compliance | **DÜŞÜK** | **DÜZELTİLDİ** (Tüm `Info.plist` dosyalarına eklendi) |
| **B16** | URL Şeması | `amnezia://` URL şemasının çakışma riski. | Guideline 2.3 | **DÜŞÜK** | **DÜZELTİLDİ** (`awgconnect://` şeması tanımlandı, geriye dönük destek korundu) |
| **B17** | UI İfadeleri | Arayüzdeki "Add Amnezia Server", "Drop Amnezia Files" marka ibareleri. | Guideline 2.3 | **DÜŞÜK** | **DÜZELTİLDİ** (Genel "AWG Connect" ve "Server" terimlerine çevrildi) |
| **B18** | Kurumsal Hesap | Apple Developer Bireysel Hesabı ile VPN uygulaması yayınlanamaması. | Guideline 5.4 | **KRİTİK** | **TAKİP İŞİ** (Şirket/Organizasyon hesabı ve D-U-N-S numarası gereklidir) |
| **B19** | Tünel Motoru | `PacketTunnelProvider` içinde gerçek WireGuard/AWG C-Go paket işleyicisi eksikliği. | Guideline 2.1 | **KRİTİK** | **TAKİP İŞİ** (`amneziawg-apple` entegrasyon iş paketi aşağıda detaylandırılmıştır) |

---

## 3. Platform Kontrol Listesi (Platform Checklists)

### A. iOS App Store Kontrol Listesi
- [x] **Display Name:** "AWG Connect" olarak ayarlandı (Maks. 30 karakter, ticari marka ihlalsiz).
- [x] **Bundle Identifier:** `com.oktayibis.awgconnect` ve `com.oktayibis.awgconnect.tunnel`.
- [x] **App Groups:** `group.com.oktayibis.awgconnect` ana uygulama ve extension'a eklendi.
- [x] **Network Extension Entitlement:** `com.apple.developer.networking.networkextension` (`packet-tunnel-provider`).
- [x] **Privacy Manifest:** `AmneziaApp/PrivacyInfo.xcprivacy` ve `AmneziaTunnel/PrivacyInfo.xcprivacy` dahil edildi.
- [x] **Gizlilik Politikası:** `PRIVACY.md` hazırlandı, sıfır loglama ve üçüncü taraf veri paylaşımı olmadığı belgelendi.
- [x] **Guideline 5.4 VPN Uyarısı & Kapısı:** İlk açılışta gösterilen `PrivacyNoticeView` onay ekranı eklendi, `interactiveDismissDisabled` ile atlanması engellendi; `AppState.toggleConnection` içinde onay doğrulanmadan tünel bağlantısına izin verilmiyor.
- [x] **Erişilebilirlik (VoiceOver - Guideline 2.5.8):** `ConnectButton` için dinamik `accessibilityLabel`, `accessibilityValue` ve `accessibilityHint` eklendi.
- [x] **Pano İzni (iOS 16+):** Otomatik okuma iptal edildi, kullanıcı tetiklemeli buton yapıldı.
- [x] **Kamera İzni:** QR kod tarayıcı için `NSCameraUsageDescription` mevcut ve amaca uygun.
- [x] **Kalan Marka Metinleri (Guideline 2.3.8):** QR paylaşım, sunucu listesi, fotoğraftan içe aktarma ve varsayılan profil adlarındaki tüm "Amnezia" ibareleri temizlendi.
- [x] **Export Compliance:** `ITSAppUsesNonExemptEncryption = false`.
- [x] **Simülasyon Koruması:** Release derlemesinde mock tünel ve sahte butonlar engellendi.

### B. macOS Mac App Store Kontrol Listesi
- [x] **Display Name:** "AWG Connect".
- [x] **Bundle Identifier:** `com.oktayibis.awgconnect.mac` ve `com.oktayibis.awgconnect.mac.tunnel`.
- [x] **App Sandbox:** `com.apple.security.app-sandbox = true`.
- [x] **Network Entitlements:** `com.apple.security.network.client = true` ve `com.apple.security.files.user-selected.read-only = true` (sürükle-bırak ve dosya içe aktarma için).
- [x] **Packet Tunnel Extension:** `AmneziaTunnelMac` target'ı ve `AmneziaTunnelMac.entitlements` oluşturuldu.
- [x] **App Groups:** `group.com.oktayibis.awgconnect` macOS ana uygulama ve tunnel extension'a eklendi.
- [x] **Privacy Manifest:** `AmneziaMac/PrivacyInfo.xcprivacy` eklendi.
- [x] **Sahte Veri Temizliği:** Sahte rastgele ping ve tanımsız 0 B/s sayaçları temizlendi.
- [x] **Açılışta Bağlan:** `connect-on-launch` işlevi ana pencere açılışına bağlandı.
- [x] **Guideline 5.4 VPN Uyarısı & Kapısı:** İlk açılışta gösterilen `MacPrivacyNoticeView` eklendi; menü çubuğundan onaysız bağlanılmaya çalışıldığında pencere öne getirilerek gizlilik bildirimi zorunlu kılındı.
- [x] **Kalan Marka Metinleri (Guideline 2.3.8):** Sunucu listesi ve içe aktarma metinlerindeki tüm marka ifadeleri güncellendi.

---

## 4. Gerçek Tünel Entegrasyon Yol Haritası (`amneziawg-apple`)

Uygulamanın canlı mağaza gönderiminde **Guideline 2.1** ret kararı almaması için uygulanması gereken teknik adımlar şunlardır:

### 1. Kütüphane Bağımlılığı (`WireGuardKit` & `amneziawg-go`):
- Standart WireGuard protokolü yerine AmneziaWG'nin özel parametrelerini (`Jc`, `Jmin`, `Jmax`, `S1`, `S2`, `H1`, `H2`, `H3`, `H4`) destekleyen Go çekirdeği kullanılmalıdır:
  - Kaynak: [amnezia-vpn/amneziawg-apple](https://github.com/amnezia-vpn/amneziawg-apple) veya [amneziawg-go](https://github.com/amnezia-vpn/amneziawg-go).
- Bu repo, iOS ve macOS mimarileri (`arm64`, `x86_64`) için static C library veya `.xcframework` üretir.

### 2. Derleme Süreci (Build Toolchain):
- `project.yml` veya Swift Package Manager içerisine bir Run Script veya SPM binary target eklenir:
  ```bash
  # Go derleme toolchain'i (macOS ve iOS Simulator/Device arm64 için)
  make -C vendor/amneziawg-apple
  ```
- Üretilen `WireGuardKit.xcframework` hem `AmneziaTunnel` (iOS) hem `AmneziaTunnelMac` (macOS) hedeflerine linklenir.

### 3. `PacketTunnelProvider.swift` Entegrasyonu:
- Mevcut `PacketTunnelProvider`, `NEPacketTunnelFlow`'dan gelen paketleri okumamakta, yalnızca sanal arayüz oluşturmaktadır.
- Yapılacak değişiklik:
  ```swift
  import WireGuardKit // veya AmneziaWGKit

  class PacketTunnelProvider: NEPacketTunnelProvider {
      private var adapter: WireGuardAdapter?

      override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
          // 1. Profil ve AWG parametrelerini ayrıştır
          guard let confString = providerConfiguration["config"] as? String,
                let wgConfig = try? parseAwgConfig(confString) else { ... }

          // 2. WireGuardAdapter'ı başlat
          self.adapter = WireGuardAdapter(with: self) { logLevel, message in
              // Loglama
          }

          // 3. Tüneli Go motoruna devret
          adapter?.start(wireguardConfig: wgConfig) { error in
              completionHandler(error)
          }
      }

      override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
          adapter?.stop { error in
              completionHandler()
          }
      }
  }
  ```

### 4. Canlı Trafik ve Byte Sayaçlarının İletimi (IPC):
- `WireGuardAdapter.getRuntimeConfiguration` metodu tünel aktifken `rx_bytes` ve `tx_bytes` değerlerini periyodik olarak döndürür.
- `PacketTunnelProvider`, bu değerleri `App Group` üzerinden paylaşılan bir `UserDefaults(suiteName: "group.com.oktayibis.awgconnect")` içine yazar veya `sendProviderMessage` ile ana uygulamaya iletir.
- Bu entegrasyon tamamlandığında `providesTrafficStats` özelliği `true` yapılarak canlı hız ve transfer grafik kartları güvenle açılır.

---

## 5. App Store Connect Gönderim Hazırlığı

### 1. Apple Developer Hesap Türü:
- **Zorunluluk:** Apple, App Store Review Guideline 5.4 uyarınca VPN uygulamalarının yalnızca **Organization (Şirket/Tüzel Kişilik)** hesaplarından sunulmasına izin verir.
- **Aksiyon:** Bir tüzel kişilik adı ve D-U-N-S numarası ile Apple Developer Organization üyeliği alınmalı veya mevcut bireysel hesap kurumsala yükseltilmelidir.

### 2. App Privacy (Gizlilik Soruları) Yanıtları:
- **Toplanan Veri Türleri:** "Data Not Collected" (Uygulama hiçbir kullanıcı verisi, kimlik, tanılama veya kullanım verisi toplamaz).
- **Takip (Tracking):** "No, we do not track users across other companies' apps and websites."
- **Privacy Policy URL:** `https://github.com/oktayibis/amnezia-clinet/blob/main/PRIVACY.md` (veya canlı web sitesi domaini).

### 3. App Review Notes (İnceleme Ekibi Notu Şablonu):
Apple inceleme ekibinin uygulamayı test edebilmesi için **App Store Connect > App Review Information** alanına eklenecek taslak metin:

```text
Dear Apple App Review Team,

AWG Connect is a client utility application designed for connecting to user-owned WireGuard and AmneziaWG servers.

1. Test Credentials & Demo Server:
To verify the VPN connectivity and packet tunnel functionality, we have provided a dedicated test configuration below. You can import this via "Import from Clipboard" or "Enter Configuration Text":

[AWG Test Configuration Link / Text Here]

2. Network Extension & Permissions:
The application uses the NetworkExtension framework (Packet Tunnel Provider). Upon tapping "Connect", iOS/macOS will prompt for system VPN configuration permission.

3. Privacy & Data Collection:
In accordance with Guideline 5.4, AWG Connect does not collect, monitor, store, or share any personal data, browsing history, or traffic metadata. A clear Privacy Notice is displayed to users on the first launch prior to establishing any connections.

4. Intellectual Property:
AWG Connect is an independent, open-source client implementing the AmneziaWG protocol. It is not affiliated with, endorsed by, or sponsored by any third-party VPN brand.

Thank you for your review.
```

---

## 6. Doğrulama ve Derleme Çıktıları

Bu hazırlık çalışması kapsamında aşağıdaki yerel kontroller başarıyla tamamlanmıştır:

1. **SPM Testleri:**
   - `swift test`: 10 test çalıştırıldı, 0 hata ile tamamlandı.
2. **Xcode Proje Üretimi:**
   - `xcodegen generate`: `AmneziaClient.xcodeproj` başarıyla üretildi.
3. **Plists & Entitlements Doğrulaması:**
   - `plutil -lint`: Tüm `.xcprivacy` ve `.entitlements` dosyaları hatasız (OK).
4. **iOS Derlemesi:**
   - `xcodebuild -scheme AmneziaApp -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`: **BUILD SUCCEEDED** (Ürün: `AWG Connect.app` ve `AmneziaTunnel.appex`).
5. **macOS Derlemesi:**
   - `xcodebuild -scheme AmneziaMac -configuration Release CODE_SIGNING_ALLOWED=NO build`: **BUILD SUCCEEDED** (Ürün: `AWG Connect.app` ve `AmneziaTunnelMac.appex`).
6. **macOS Tunnel Target Derlemesi:**
   - `xcodebuild -target AmneziaTunnelMac -configuration Release CODE_SIGNING_ALLOWED=NO build`: **BUILD SUCCEEDED**.

---

# BÖLÜM 2 — Android & Android TV: Google Play İnceleme Hazırlık Raporu

**Modüller:** `AmneziaAndroid/core`, `AmneziaAndroid/mobile` (telefon, `com.oktayibis.awgconnect`), `AmneziaAndroid/tv` (Android TV, `com.oktayibis.awgconnect.tv`)  
**Araç zinciri:** Gradle 8.11.1 · AGP 8.9.3 · Kotlin 2.0.21 · Compose BOM 2025.06.01 · compileSdk 36  
**Hedef API:** telefon 36 (Play'in 31 Ağustos 2026 sonrası yeni uygulama şartı), TV 35 (TV için asgari 34)

## 7. Yönetici Özeti (Android)

> [!IMPORTANT]
> Bu tur sonunda Android ve Android TV uygulamaları **hedef API, R8/minify, imzalama altyapısı, foreground VpnService iskeleti, sistem VPN izin akışı, yedekleme kapatma, Play VpnService beyan ekranı, gizlilik politikası ve marka** açısından Google Play standartlarına getirildi.
> Ancak iOS/macOS ile aynı temel eksik burada da geçerlidir: **`AmneziaVpnService` TUN arayüzünü kurar fakat WireGuard/AmneziaWG şifreleme ve paket iletimi yapmaz.** `amneziawg-android` backend'i entegre edilene kadar Play'e **gönderilmemelidir**; aksi halde "işlevsiz uygulama" ve VpnService politikasının "cihazdan tünel ucuna şifreli veri" şartı gerekçesiyle ret alınır.

## 8. Bulgular ve Düzeltmeler Tablosu (Android, 24 Madde)

| No | Kategori | Bulgu | Play Politikası / Gereksinim | Önem | Durum |
|:---|:---|:---|:---|:---:|:---:|
| **A1** | İşlevsellik | `MobileAppState`/`TvAppState` her zaman `MockTunnelService` kullanıyordu; gerçek `VpnService` hiç başlatılmıyordu, "Connection Encrypted" yazıyordu. | Yanıltıcı İddialar, VpnService Politikası | **KRİTİK** | **DÜZELTİLDİ** (`RealTunnelService` eklendi; Mock yalnızca `BuildConfig.DEBUG`) |
| **A2** | VPN Servisi | `VpnService.prepare()` yok, profil verisi kullanılmıyor, `startForeground()` yok, `foregroundServiceType` yok. | Android 14 FGS türü zorunluluğu, VpnService Politikası | **KRİTİK** | **DÜZELTİLDİ** (izin akışı, `systemExempted` FGS + bildirim, profilden adres/rota/DNS/MTU) |
| **A3** | Play Console | VpnService beyan formu, Data Safety, gizlilik politikası URL'i, uygulama içi beyan yok. | VpnService Politikası, Kullanıcı Verileri | **KRİTİK** | **KISMEN** (uygulama içi ilk açılış beyanı + `PRIVACY.md` eklendi; Console formları takip işi) |
| **A4** | Marka | `org.amnezia.mobile`/`org.amnezia.tv`, "Amnezia"/"Amnezia TV" etiketleri. | Taklit (Impersonation) | **KRİTİK** | **DÜZELTİLDİ** (`com.oktayibis.awgconnect[.tv]`, "AWG Connect [TV]") |
| **A5** | Hedef API | `mobile` targetSdk 35; 31 Ağustos 2026'dan itibaren yeni uygulamalar için 36 şart. | Target API Level | **KRİTİK** | **DÜZELTİLDİ** (telefon 36, TV 35, compileSdk 36, AGP 8.9.3) |
| **A6** | Lisans | LICENSE yok. | Açık kaynak | **KRİTİK** | **DÜZELTİLDİ** (repo kökünde MIT) |
| **A7** | Yanıltıcı UI | Rastgele hız/ping üreten simülasyon üretimde, varsayılan açık. | Yanıltıcı İddialar | **YÜKSEK** | **DÜZELTİLDİ** (release'de erişilemez; rozet/toggle `BuildConfig.DEBUG`) |
| **A8** | Ayarlar | Kill Switch ve DNS seçimi kalıcı değildi ve servise gitmiyordu. Android'de uygulama kill switch kuramaz. | İşlevsellik | **YÜKSEK** | **DÜZELTİLDİ** (`AppSettings` kalıcı; DNS `Builder.addDnsServer`; Kill Switch satırı sistem Always-on VPN ayarına yönlendiriyor) |
| **A9** | Güvenlik | Özel anahtarlar düz SharedPreferences + `allowBackup="true"`. | Kullanıcı Verileri | **YÜKSEK** | **KISMEN** (`allowBackup="false"`; Keystore ile şifreleme takip işi) |
| **A10** | Pano | Her `onResume`'da pano okunuyordu (Android 12+ uyarısı). | Kullanıcı Verileri | **YÜKSEK** | **DÜZELTİLDİ** (yalnızca "Import from clipboard" butonu) |
| **A11** | Derleme | R8 kapalı, ProGuard dosyaları eksik. | Uygulama kalitesi | **YÜKSEK** | **DÜZELTİLDİ** (`isMinifyEnabled` + `isShrinkResources`, serialization keep kuralları) |
| **A12** | İmzalama | Release imzalama yapılandırması yok. | Play App Signing | **YÜKSEK** | **DÜZELTİLDİ** (`keystore.properties` tabanlı `signingConfigs.release`; dosya git dışı) |
| **A13** | Paketleme | Yalnızca APK üretiliyordu. | AAB zorunluluğu | **YÜKSEK** | **DÜZELTİLDİ** (`bundleRelease` doğrulandı) |
| **A14** | İkon | Adaptive icon yok (lint `IconLauncherShape`). | Kalite | **ORTA** | **DÜZELTİLDİ** (`mipmap-anydpi-v26` + foreground/background) |
| **A15** | Sürüm metni | Sabit "1.0.0 (Build 1)". | Kalite | **DÜŞÜK** | **DÜZELTİLDİ** (`BuildConfig.VERSION_NAME/CODE`) |
| **A16** | Manifest | `android:label` sabit metin. | Lokalizasyon | **DÜŞÜK** | **DÜZELTİLDİ** (`@string/app_name`) |
| **A17** | Bağımlılık | `tv-foundation` alfa bağımlılığı (kullanılmıyordu). | Kararlılık | **DÜŞÜK** | **DÜZELTİLDİ** (kaldırıldı) |
| **A18** | Boyut | ML Kit bundled model. | Opsiyonel | **DÜŞÜK** | **TAKİP** (`play-services-mlkit-barcode-scanning` alternatifi) |
| **A19** | Model | `ServerProfile` iOS ile eşdeğer değil (S3/S4, I1–I5, keepalive). | Tünel entegrasyonu | **DÜŞÜK** | **TAKİP** (backend entegrasyonuyla birlikte) |
| **A20** | Kod kalitesi | Mock scope sızıntısı, gereksiz `Application.instance`. | — | **DÜŞÜK** | **TAKİP** |
| **A21** | Deep link | Yalnızca `vpn` şeması. | — | **DÜŞÜK** | **DÜZELTİLDİ** (`awgconnect://` eklendi) |
| **A22** | Lokalizasyon | Tüm metinler Kotlin içinde. | — | **DÜŞÜK** | **TAKİP** |
| **A23** | 16 KB sayfa | Native `.so` gelince zorunlu. | 16 KB uyumluluğu | **ORTA** | **TAKİP** (backend seçiminde uyumlu sürüm) |
| **A24** | Lint | `lintRelease` `UnsafeOptInUsageError` ile başarısızdı. | CI | **ORTA** | **DÜZELTİLDİ** (`@androidx.annotation.OptIn(ExperimentalGetImage::class)`) |

## 9. Google Play Console Kontrol Listesi

### A. Telefon (`com.oktayibis.awgconnect`)
- [x] `targetSdk 36`, `compileSdk 36`, AGP 8.9.3.
- [x] `android:allowBackup="false"` (özel anahtarlar yedeğe gitmez).
- [x] `AmneziaVpnService`: `BIND_VPN_SERVICE`, `foregroundServiceType="systemExempted"`, `FOREGROUND_SERVICE_SYSTEM_EXEMPTED` izni, kalıcı bildirim + "Disconnect" aksiyonu, `onRevoke()`.
- [x] `VpnService.prepare()` onay akışı `MainActivity` içinde `ActivityResult` ile.
- [x] Android 13+ `POST_NOTIFICATIONS` runtime isteği.
- [x] İlk açılışta `PrivacyNoticeScreen` (Play VpnService beyanı); Settings → Privacy Policy linki.
- [x] Pano yalnızca kullanıcı dokunuşuyla okunur.
- [x] R8 + resource shrinking; `bundleRelease` üretir; imza `keystore.properties` ile.
- [x] Adaptive icon; `@string/app_name`.
- [ ] **Play Console → App content → VpnService beyanı:** "Core VPN functionality" seçilir; açıklama: kullanıcıya ait WireGuard/AmneziaWG sunucularına istemci; veri toplanmaz.
- [ ] **Data Safety:** "Veri toplanmıyor / paylaşılmıyor"; şifreleme: evet (tünel); silme: uygulama verisi.
- [ ] **Gizlilik politikası URL'i:** `https://github.com/oktayibis/amnezia-clinet/blob/main/PRIVACY.md` (veya kendi alan adınız).
- [ ] **Mağaza açıklaması:** VpnService kullanımı ve "kendi sunucunuz gerekir" ifadesi açıkça yazılır.
- [ ] **Upload keystore** oluşturulup Play App Signing'e kaydedilir.
- [ ] Gerçek tünel backend'i entegre edilmeden **gönderilmez**.

### B. Android TV (`com.oktayibis.awgconnect.tv`)
- [x] `targetSdk 35` (TV için asgari 34), `leanback` zorunlu, `touchscreen` zorunlu değil, 320×180 banner.
- [x] Kamera izni yok; içe aktarma dosya/URL ile.
- [x] Tüm ekranlar D-pad ile gezilebilir (`TvFocusableCard`), tek odak hedefli beyan ekranı.
- [x] Aynı VpnService/izin akışı; `POST_NOTIFICATIONS`.
- [ ] Play Console'da TV form factor'ü için ayrı inceleme (ekran görüntüleri 1920×1080, banner) ve aynı VpnService beyanı.

## 10. Gerçek Tünel Entegrasyon Yol Haritası (Android)

1. **Backend:** `com.zaneschepke:amneziawg-android` (Maven Central, Apache-2.0; amneziawg-go tabanlı `GoBackend`) veya `amnezia-vpn/amneziawg-android` kaynak derlemesi (Go + NDK). 16 KB sayfa uyumlu sürüm seçilir; AGP ≥ 8.5.1 zaten sağlanıyor.
2. **Yapılandırma dönüşümü:** `ServerProfile` → `org.amnezia.awg.config.Config` (Interface: private key, addresses, DNS, MTU, Jc/Jmin/Jmax/S1/S2/H1–H4; Peer: public key, PSK, endpoint, allowed IPs, keepalive). `ServerProfile`'a eksik alanlar (A19) eklenir.
3. **Servis:** `AmneziaVpnService` yerine kütüphanenin `GoBackend.VpnService` alt sınıfı; `RealTunnelService.startTunnel` → `backend.setState(tunnel, Tunnel.State.UP, config)`. Mevcut bildirim, izin ve DNS override mantığı korunur.
4. **İstatistik:** `backend.getStatistics(tunnel)` ile rx/tx byte'ları `ConnectionStats`'a; `providesTrafficStats = true` yapılır ve hız kartları otomatik görünür.
5. **Doğrulama:** 16 KB emülatörde (`bundletool build-apks --connected-device`) kurulum; `adb shell dumpsys activity services` ile FGS tipi; gerçek sunucuya bağlanıp `curl ifconfig.me` çıkışı.

## 11. Doğrulama ve Derleme Çıktıları (Android)

__ANDROID_VERIFICATION__

---
*Hazırlayan: Oktay İbiş*  
*Belge Konumu:* `docs/store-review-analysis.md`
