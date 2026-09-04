import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Biletleme firmaları. Renkleri sabit ve global — donut, legend, yatay barlar
/// ve Firmalar raporunda her yerde aynı token kullanılır.
enum Vendor {
  biletix('Biletix', AppColors.vendorBiletix),
  bubilet('Bubilet', AppColors.vendorBubilet),
  biletinial('Biletinial', AppColors.vendorBiletinial),
  diger('Diğer', AppColors.vendorDiger);

  const Vendor(this.label, this.color);

  /// Arayüzde görünen ad.
  final String label;

  /// `vendor.*` renk token'ı.
  final Color color;
}

/// Bir firmanın tek bir gösteri ya da dönemdeki payı.
@immutable
class VendorShare {
  const VendorShare({
    required this.vendor,
    required this.sold,
    required this.pct,
  });

  final Vendor vendor;

  /// Satılan bilet adedi.
  final int sold;

  /// Yüzde payı (`43.9` → `%43,9`).
  final double pct;
}
