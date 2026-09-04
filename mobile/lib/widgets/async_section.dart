import 'package:flutter/material.dart';

import 'state_views.dart';

/// Bir future'ın loading / error / empty / data durumlarını tek yerde çözer.
///
/// Her ekran bu sarmalayıcıyı kullanır; böylece dört durum da her yerde aynı
/// biçimde görünür ve tekrarlanmaz.
class AsyncSection<T> extends StatelessWidget {
  const AsyncSection({
    super.key,
    required this.future,
    required this.builder,
    required this.skeleton,
    this.isEmpty,
    this.emptyMessage = 'Gösterilecek veri yok',
    this.emptyActionLabel,
    this.onEmptyAction,
    this.onRetry,
  });

  final Future<T>? future;

  /// Veri geldiğinde çizilecek içerik.
  final Widget Function(BuildContext context, T data) builder;

  /// Yükleme sırasında gösterilecek iskelet.
  final Widget skeleton;

  /// Verinin boş sayılma koşulu; verilmezse boş durumu denetlenmez.
  final bool Function(T data)? isEmpty;

  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  /// Hata durumundaki "Yeniden dene" eylemi.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return skeleton;
        }
        if (snapshot.hasError) {
          return ErrorState(onRetry: onRetry);
        }
        final data = snapshot.data as T;
        if (isEmpty?.call(data) ?? false) {
          return EmptyState(
            message: emptyMessage,
            actionLabel: emptyActionLabel,
            onAction: onEmptyAction,
          );
        }
        return builder(context, data);
      },
    );
  }
}
