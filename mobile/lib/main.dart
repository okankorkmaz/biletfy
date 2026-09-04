import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/formatters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tüm tarih biçimleri tr_TR.
  await initializeDateFormatting(Tr.locale);
  runApp(const BiletfyApp());
}
