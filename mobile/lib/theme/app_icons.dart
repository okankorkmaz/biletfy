import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// İkon token'ları — tek set (Lucide), karıştırma yok.
///
/// Semantik adlar tek yerde eşlenir; bileşenler doğrudan [LucideIcons]'a
/// bakmaz. Set değişirse yalnızca bu dosya güncellenir.
abstract final class AppIcons {
  // Alt navigasyon.
  static const IconData navHome = LucideIcons.home;
  static const IconData navEvents = LucideIcons.ticket;
  static const IconData navReports = LucideIcons.barChart2;
  static const IconData navCalendar = LucideIcons.calendar;
  static const IconData navSettings = LucideIcons.settings;

  // App bar aksiyonları.
  static const IconData menu = LucideIcons.menu;
  static const IconData back = LucideIcons.arrowLeft;
  static const IconData search = LucideIcons.search;
  static const IconData close = LucideIcons.x;
  static const IconData share = LucideIcons.share2;
  static const IconData bell = LucideIcons.bell;
  static const IconData calendarAction = LucideIcons.calendarDays;

  // KPI ikonları.
  static const IconData totalEvents = LucideIcons.ticket;
  static const IconData totalSold = LucideIcons.ticketCheck;
  static const IconData revenue = LucideIcons.banknote;
  static const IconData occupancy = LucideIcons.trendingUp;
  static const IconData avgTicketPrice = LucideIcons.tag;

  // Satır içi.
  static const IconData mapPin = LucideIcons.mapPin;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData clock = LucideIcons.clock;
  static const IconData trendUp = LucideIcons.trendingUp;
  static const IconData trendDown = LucideIcons.trendingDown;

  // Chevron'lar.
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronRight = LucideIcons.chevronRight;

  // Ayarlar ve bildirimler.
  static const IconData user = LucideIcons.userCircle;
  static const IconData notificationPrefs = LucideIcons.bellRing;
  static const IconData integrations = LucideIcons.link;
  static const IconData locale = LucideIcons.globe;
  static const IconData about = LucideIcons.info;
  static const IconData logout = LucideIcons.logOut;
  static const IconData mail = LucideIcons.mail;
  static const IconData lock = LucideIcons.lockKeyhole;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  static const IconData arrowRight = LucideIcons.arrowRight;
  static const IconData fingerprint = LucideIcons.fingerprint;
  static const IconData shieldCheck = LucideIcons.shieldCheck;

  // Durumlar.
  static const IconData empty = LucideIcons.inbox;
  static const IconData error = LucideIcons.alertCircle;
  static const IconData offline = LucideIcons.wifiOff;
  static const IconData retry = LucideIcons.refreshCw;
}
