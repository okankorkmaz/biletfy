import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../core/formatters.dart';
import '../models/event.dart';

abstract final class EventShareService {
  static Future<void> share({
    required Event event,
    required Show? show,
    required Rect origin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        title: event.title,
        subject: '${event.title} etkinlik bilgisi',
        text: message(event: event, show: show),
        sharePositionOrigin: origin,
      ),
    );
  }

  static String message({required Event event, required Show? show}) {
    return [
      'biletify etkinliği',
      event.title,
      if (show != null) Tr.dateTime(show.dateTime),
      if (show != null) show.locationLabel,
      'Durum: ${event.status.label}',
    ].join('\n');
  }
}
