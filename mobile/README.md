# Etkinlik & Bilet Satış Takip — mobil

BKM Mutfak prodüksiyon ekibi için dahili operasyon uygulaması. Flutter,
Material 3, **yalnızca koyu tema** (`lightTheme` tanımlı değil, `ThemeMode.dark`
sabit). Tasarım çerçevesi 390×844, tüm metinler tr_TR.

Kaynak tasarım: `../design/Tasarim Sistemi.dc.html` ve
`../design/Bilesen Kutuphanesi.dc.html`.

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Kontroller

```bash
flutter analyze     # 0 sorun
flutter test        # 26 test
```

## Mimari

```
lib/
  theme/        Token katmanı — Token JSON'un birebir karşılığı
  core/         tr_TR biçimlendirme (Tr)
  models/       Event · Show · Vendor · rapor ve bildirim modelleri
  data/         DashboardRepository arayüzü + mock/ implementasyonu
  widgets/      23 bileşen + destek bileşenleri
  screens/      Ekranlar
  dev/          Bileşen galerisi (yalnızca debug)
```

### Token kuralı

Hiçbir widget'ta hardcoded hex, font boyutu veya padding yoktur. Her değer
`AppColors` · `AppTypography` · `AppSpace` · `AppRadius` · `AppSize` ·
`AppIconSize` · `AppIcons` üzerinden gelir. Gölge, elevation ve blur yok —
tamamen flat.

Sayısal tipografi token'larında `FontFeature.tabularFigures()` zorunludur;
sağa dayalı değer kolonları ancak böyle hizalanır.

### Veri katmanı

UI hiçbir yerde mock'a doğrudan bakmaz. Ekranlar yalnızca
`RepositoryScope.of(context)` ile `DashboardRepository` arayüzünü görür.
API'ye geçmek için `lib/app.dart` içinde takılan implementasyonu değiştirmek
yeterlidir; ekranlarda tek satır değişmez.

`MockDashboardRepository` ağ gecikmesini taklit eder ve `failing` / `empty`
bayraklarıyla hata ve boş durumların provası yapılabilir.

Mock veri seti 15 Mayıs 2026 merkezlidir. Ekranlar cihaz saatine değil
`repository.referenceDate` değerine bakar.

### Ekranlar

| Ekran | Dosya | Not |
|---|---|---|
| 01 Ana Sayfa | `screens/home/` | KPI 2×2 · donut · günlük özet |
| 02 Etkinlikler | `screens/events/events_screen.dart` | 4 durum filtresi |
| 03 · 11 · 12 Etkinlik Detayı | `screens/event_detail/` | 3 sekme, alt navigasyon gizli |
| 04 Günlük Satış | `screens/daily_sales/` | Push; gövdesi detay sekmesinde de kullanılır |
| 05 · 13 · 14 · 15 Raporlar | `screens/reports/` | Satış · Gelir · Doluluk · Firmalar |
| 06 Takvim | `screens/calendar/` | Pazartesi başlangıçlı |
| 07 Ayarlar | `screens/settings/` | Hesap · bildirim · veri kaynakları · biçim |
| 08 Bildirimler | `screens/notifications/` | Push, tarih gruplu |
| 09 Arama | `screens/events/search_screen.dart` | Push |
| 10 Drawer | `widgets/app_drawer.dart` | Kök ekranlarda hamburgerden |

5 sekmeli `AppBottomNav` yalnızca `RootShell` içinde görünür; push edilen
ekranlarda otomatik olarak gizlenir.

Her ekranda yükleme (skeleton), boş ve hata durumu vardır; dördü de
`AsyncSection` üzerinden tek biçimde çözülür.

### Bileşen galerisi

Debug derlemesinde drawer'ın altındaki **Bileşen Kütüphanesi** satırından ya da
`/dev/gallery` rotasından açılır. 23 bileşenin tamamı varyant ve durumlarıyla,
her başlıkta HTML'deki ölçü notuyla listelenir. Release derlemesinde rota
kaydedilmez.

## Bilinmesi gerekenler

- `lucide_icons` paketi güncel Flutter ile derlenmiyor (`IconData` artık
  `final class`). Bakımlı fork `lucide_icons_flutter` kullanılıyor.
- KPI kartının doğal yüksekliği 102 pt'dir (şartnamedeki "~88" yaklaşıktır);
  HTML referansındaki kart da 102 pt. Sabit yükseklik dayatılmaz.
- Günlük satış özeti değerleri şartname bölüm 10/2 düzeltmesiyle
  Dün +444 · Bugün +529'dur (kolajdaki 368/512 değil).
- Windows masaüstü hedefi yalnızca önizleme içindir; pencere 390×844'e
  sabitlenmiştir (`windows/runner/main.cpp`).
