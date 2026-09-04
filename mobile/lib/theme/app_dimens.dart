import 'package:flutter/material.dart';

/// Boşluk token'ları — Token JSON `space` bloğu. 8 pt grid, 4 pt yarım adım.
///
/// Kural: hiçbir widget'ta hardcoded padding bulunmaz; her ölçü buradan gelir.
abstract final class AppSpace {
  /// Ekran yatay padding.
  static const double screenX = 16;

  /// Kart iç padding.
  static const double cardPadding = 16;

  /// Kartlar arası boşluk.
  static const double cardGap = 12;

  /// Bölüm başlığı ile kart arası.
  static const double titleGap = 8;

  /// Bölümler arası.
  static const double sectionGap = 20;

  /// Chip'ler arası.
  static const double chipGap = 8;

  /// 4 pt yarım adım — ikon/metin arası gibi mikro boşluklar.
  static const double xs = 4;

  /// 2 pt — etiket ile değeri arasındaki en dar aralık.
  static const double xxs = 2;

  /// 6 pt — satır içi ikon boşluğu.
  static const double sm = 6;

  /// 10 pt — hücre iç padding'i, ikon konteyneri ile etiket arası.
  static const double md = 10;

  /// Liste kartı iç padding'i.
  static const double listCardPadding = 12;
}

/// Köşe yarıçapı token'ları — Token JSON `radius` bloğu.
abstract final class AppRadius {
  /// Kart.
  static const double card = 16;

  /// Kart içi hücre / chip kutusu.
  static const double cell = 12;

  /// İkon konteyneri.
  static const double icon = 10;

  /// Liste kartındaki afiş küçük resmi.
  static const double posterList = 10;

  /// Detay ekranındaki afiş.
  static const double posterDetail = 12;

  /// Pill ve progress.
  static const double pill = 999;

  /// Bar grafik üst köşeleri.
  static const double barTop = 4;

  /// Saat kutusu (DayEventRow).
  static const double timeBox = 8;

  static BorderRadius get cardR => BorderRadius.circular(card);
  static BorderRadius get cellR => BorderRadius.circular(cell);
  static BorderRadius get iconR => BorderRadius.circular(icon);
  static BorderRadius get pillR => BorderRadius.circular(pill);
  static BorderRadius get posterListR => BorderRadius.circular(posterList);
  static BorderRadius get posterDetailR => BorderRadius.circular(posterDetail);
  static BorderRadius get timeBoxR => BorderRadius.circular(timeBox);
}

/// Sabit ölçü token'ları — Token JSON `size` bloğu.
abstract final class AppSize {
  static const double appBar = 56;
  static const double bottomNav = 56;

  static const double filterChip = 32;
  static const double filterChipPaddingX = 14;
  static const double dropdownChip = 28;
  static const double dropdownChipPaddingX = 12;

  /// Durum pill'i (detay ekranı).
  static const double statusPill = 24;
  static const double statusPillPaddingX = 10;

  /// Doluluk değişim rozeti.
  static const double deltaBadge = 20;
  static const double deltaBadgePaddingX = 8;

  /// Progress kalınlıkları: liste kartı / detay doluluk / firma barları.
  static const double progressList = 4;
  static const double progressDetail = 6;
  static const double progressVendor = 4;

  static const double calendarCell = 40;

  static const double donutDiameter = 120;
  static const double donutThickness = 24;

  /// Minimum dokunma hedefi.
  static const double minTouch = 44;

  /// KPI ikon konteyneri.
  static const double iconBox = 32;

  /// Afiş placeholder ölçüleri.
  static const double posterList = 76;
  static const double posterDetail = 96;

  /// Logo placeholder (Ana Sayfa app bar).
  static const Size logoPlaceholder = Size(64, 32);

  /// Saat kutusu (DayEventRow).
  static const Size timeBox = Size(52, 32);

  /// Legend yüzde kolonu — sağa dayalı sabit genişlik.
  static const double legendPctColumn = 52;

  /// Firma barı yüzde kolonu — sağa dayalı sabit genişlik.
  static const double vendorPctColumn = 48;

  /// DataRowList satır yüksekliği.
  static const double dataRow = 44;

  /// Kart kenarlığı kalınlığı.
  static const double borderWidth = 1;

  /// "Bugün" halkası kalınlığı (takvim).
  static const double todayRingWidth = 1.5;

  /// Aktif sekme alt çizgisi.
  static const double tabUnderline = 2;

  /// Takvimde etkinlikli gün noktası.
  static const double eventDot = 4;

  /// Legend renk noktası.
  static const double legendDot = 8;

  /// Okunmamış bildirim noktası.
  static const double unreadDot = 6;

  /// Grafik çizgi kalınlığı ve nokta yarıçapı.
  static const double chartLine = 2;
  static const double chartDot = 6;

  /// Bar grafik genişliği.
  static const double chartBar = 32;

  /// SegmentedTabs yüksekliği.
  static const double segmentedTabs = 48;

  /// İkincil buton yüksekliği (boş/hata durumu).
  static const double secondaryButton = 36;

  /// Boş/hata durumu ikon konteyneri.
  static const double stateIconBox = 48;
}

/// İkon boyutu token'ları — tek set (Lucide), karıştırma yok.
abstract final class AppIconSize {
  /// Alt navigasyon ve app bar aksiyonları.
  static const double nav = 24;

  /// Satır içi.
  static const double inline = 20;

  /// KPI ikon konteyneri içi.
  static const double kpi = 18;

  /// Chip ve etiket içi.
  static const double chip = 16;

  /// Dropdown chevron'u.
  static const double chevron = 14;

  /// Boş/hata durumu ikonu.
  static const double state = 20;
}
