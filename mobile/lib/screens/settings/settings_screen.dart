import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/reports.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

/// Uygulama sürümü — tek yerde tutulur (drawer da buradan okur).
const String kAppVersion = '0.1.0 (1)';

/// 07_Ayarlar — kök sekme.
///
/// Hesap · bildirim tercihleri · veri kaynakları · biçim · hakkında.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DashboardRepository _repository;

  bool _dailySummaryEnabled = true;
  TimeOfDay _summaryTime = const TimeOfDay(hour: 9, minute: 0);
  bool _occupancyAlertEnabled = true;
  int _occupancyThreshold = 75;

  Future<List<VendorIntegration>>? _integrations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _integrations = _repository.integrations();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _summaryTime,
      builder: (context, child) => MediaQuery(
        // 24 saat biçimi — tr_TR kuralı.
        data: MediaQuery.of(
          context,
        ).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _summaryTime = picked);
  }

  Future<void> _pickThreshold() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.cardPadding,
                AppSpace.cardPadding,
                AppSpace.cardPadding,
                AppSpace.titleGap,
              ),
              child: Text('Doluluk eşiği', style: AppTypography.titleM),
            ),
            for (final threshold in const [50, 60, 70, 75, 80, 90])
              ListTile(
                minTileHeight: AppSize.minTouch,
                title: Text(
                  Tr.percent(threshold),
                  style: AppTypography.body,
                ),
                selected: threshold == _occupancyThreshold,
                selectedColor: AppColors.primary,
                onTap: () => Navigator.of(context).pop(threshold),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _occupancyThreshold = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.root(
        title: 'Ayarlar',
        onMenuTap: widget.onOpenDrawer,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screenX,
          AppSpace.cardPadding,
          AppSpace.screenX,
          AppSpace.sectionGap,
        ),
        children: [
          SettingsGroup(
            title: 'Hesap',
            rows: [
              SettingsRow(
                label: 'Okan Korkmaz',
                detail: 'Prodüksiyon · BKM Mutfak',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sectionGap),

          SettingsGroup(
            title: 'Bildirimler',
            rows: [
              SettingsRow(
                label: 'Günlük satış özeti',
                detail: 'Her gün belirlenen saatte gönderilir',
                trailing: Switch(
                  value: _dailySummaryEnabled,
                  onChanged: (value) =>
                      setState(() => _dailySummaryEnabled = value),
                ),
              ),
              SettingsRow(
                label: 'Özet saati',
                value: _formatTime(_summaryTime),
                onTap: _dailySummaryEnabled ? _pickTime : null,
              ),
              SettingsRow(
                label: 'Doluluk eşiği uyarısı',
                detail: 'Eşik aşıldığında bildirim gönderilir',
                trailing: Switch(
                  value: _occupancyAlertEnabled,
                  onChanged: (value) =>
                      setState(() => _occupancyAlertEnabled = value),
                ),
              ),
              SettingsRow(
                label: 'Eşik',
                value: Tr.percent(_occupancyThreshold),
                onTap: _occupancyAlertEnabled ? _pickThreshold : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sectionGap),

          _IntegrationsGroup(future: _integrations, onRetry: _load),
          const SizedBox(height: AppSpace.sectionGap),

          const SettingsGroup(
            title: 'Biçim',
            rows: [
              SettingsRow(label: 'Para birimi', value: 'Türk lirası (₺)'),
              SettingsRow(label: 'Tarih biçimi', value: '15 Mayıs 2026'),
              SettingsRow(label: 'Haftanın ilk günü', value: 'Pazartesi'),
              SettingsRow(label: 'Dil', value: 'Türkçe'),
            ],
          ),
          const SizedBox(height: AppSpace.sectionGap),

          SettingsGroup(
            title: 'Hakkında',
            rows: [
              const SettingsRow(label: 'Sürüm', value: kAppVersion),
              SettingsRow(
                label: 'Çıkış',
                labelColor: AppColors.danger,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 24 saat biçimi — `09:00`.
  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Veri kaynakları grubu — firma entegrasyonlarının bağlantı durumu.
class _IntegrationsGroup extends StatelessWidget {
  const _IntegrationsGroup({required this.future, required this.onRetry});

  final Future<List<VendorIntegration>>? future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AsyncSection<List<VendorIntegration>>(
      future: future,
      onRetry: onRetry,
      isEmpty: (items) => items.isEmpty,
      emptyMessage: 'Tanımlı veri kaynağı yok',
      skeleton: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 12, width: 100),
            SizedBox(height: AppSpace.titleGap),
            SkeletonBox(height: 180, radius: AppRadius.card),
          ],
        ),
      ),
      builder: (context, items) => SettingsGroup(
        title: 'Veri kaynakları',
        rows: [
          for (final item in items)
            SettingsRow(
              label: item.vendor.label,
              detail: item.connected
                  ? 'Son eşitleme ${Tr.shortStamp(item.lastSync!)}'
                  : 'Bağlı değil',
              leadingColor: item.connected
                  ? AppColors.success
                  : AppColors.textTertiary,
              value: item.connected ? 'Bağlı' : 'Bağla',
              onTap: () {},
            ),
        ],
      ),
    );
  }
}
