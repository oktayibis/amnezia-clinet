# AWG Connect — App Store & Mac App Store İnceleme Hazırlık Raporu

**Tarih:** 12 Eylül 2026  
**Uygulama Adı:** AWG Connect (Eski Kod Adı: Amnezia Client)  
**Paket Kimliği (Bundle Identifier):** `com.oktayibis.awgconnect`  
**Geliştirici:** Oktay İbiş  
**Hedef Platformlar:** iOS 17.0+ (iPhone, iPad), macOS 14.0+ (Apple Silicon & Intel)

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
- [x] **Guideline 5.4 VPN Uyarısı:** İlk açılışta gösterilen `PrivacyNoticeView` onay ekranı eklendi.
- [x] **Pano İzni (iOS 16+):** Otomatik okuma iptal edildi, kullanıcı tetiklemeli buton yapıldı.
- [x] **Kamera İzni:** QR kod tarayıcı için `NSCameraUsageDescription` mevcut ve amaca uygun.
- [x] **Export Compliance:** `ITSAppUsesNonExemptEncryption = false`.
- [x] **Simülasyon Koruması:** Release derlemesinde mock tünel ve sahte butonlar engellendi.

### B. macOS Mac App Store Kontrol Listesi
- [x] **Display Name:** "AWG Connect".
- [x] **Bundle Identifier:** `com.oktayibis.awgconnect.mac` ve `com.oktayibis.awgconnect.mac.tunnel`.
- [x] **App Sandbox:** `com.apple.security.app-sandbox = true`.
- [x] **Network Entitlements:** `com.apple.security.network.client = true` ve `com.apple.security.network.server = true`.
- [x] **Packet Tunnel Extension:** `AmneziaTunnelMac` target'ı ve `AmneziaTunnelMac.entitlements` oluşturuldu.
- [x] **App Groups:** `group.com.oktayibis.awgconnect` macOS ana uygulama ve tunnel extension'a eklendi.
- [x] **Privacy Manifest:** `AmneziaMac/PrivacyInfo.xcprivacy` eklendi.
- [x] **Sahte Veri Temizliği:** Sahte rastgele ping ve tanımsız 0 B/s sayaçları temizlendi.
- [x] **Açılışta Bağlan:** `connect-on-launch` işlevi ana pencere açılışına bağlandı.
- [x] **Guideline 5.4 VPN Uyarısı:** İlk açılışta gösterilen `MacPrivacyNoticeView` eklendi.

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
*Hazırlayan: Oktay İbiş*  
*Belge Konumu:* `docs/store-review-analysis.md`
