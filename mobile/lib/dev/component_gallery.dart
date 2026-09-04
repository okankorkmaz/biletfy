import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../data/mock/mock_fixtures.dart';
import '../models/event.dart';
import '../models/vendor.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Bileşen galerisi — `design/Bilesen Kutuphanesi.dc.html` ile yan yana
/// karşılaştırmak için 23 bileşenin tamamı, varyant ve durumlarıyla.
///
/// Yalnızca debug derlemesinde açılır ([ComponentGalleryScreen.routeName]).
/// Release'te [ComponentGalleryScreen.isAvailable] `false` döner ve rota
/// kaydedilmez.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  static const String routeName = '/dev/gallery';

  /// Rota yalnızca debug derlemesinde kayıtlıdır.
  static bool get isAvailable => kDebugMode;

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  int _filterIndex = 0;
  int _tabIndex = 0;
  RootTab _navTab = RootTab.home;
  String _period = 'Bugün';
  DateTime _calendarMonth = DateTime(2026, 5);
  DateTime _selectedDay = DateTime(2026, 5, 15);

  final TextEditingController _searchController = TextEditingController();

  Show get _show => MockFixtures.shows.first;

  /// Firma bazlı seriler — payları sabit oranla dağıtılmış demo verisi.
  Map<Vendor, List<DailySales>> get _vendorSeries => {
    for (final stat in MockFixtures.vendorStats)
      stat.vendor: [
        for (final point in MockFixtures.dailySales)
          DailySales(
            date: point.date,
            sold: (point.sold * stat.pct / 100).round(),
          ),
      ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.push(
        title: 'Bileşen Kütüphanesi',
        subtitle: '23 bileşen · 390 pt @1x',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screenX,
          AppSpace.titleGap,
          AppSpace.screenX,
          AppSpace.sectionGap * 2,
        ),
        children: [
          _Section(
            number: '01',
            name: 'TopBar',
            spec: 'h 56 · yatay padding 16 · ikon 24 · başlık titleM ortalı',
            variants: [
              _Variant(
                'a · kök · Ana Sayfa (logo placeholder)',
                _BarFrame(
                  child: AppTopBar.home(
                    action: const TopBarAction(
                      icon: AppIcons.bell,
                      tooltip: 'Bildirimler',
                    ),
                  ),
                ),
              ),
              _Variant(
                'b · kök sekme',
                _BarFrame(
                  child: AppTopBar.root(
                    title: 'Etkinlikler',
                    onMenuTap: () {},
                    action: const TopBarAction(
                      icon: AppIcons.search,
                      tooltip: 'Ara',
                    ),
                  ),
                ),
              ),
              _Variant(
                'c · push ekran',
                _BarFrame(
                  child: AppTopBar.push(
                    title: 'Etkinlik Detayı',
                    onBackTap: () {},
                    action: const TopBarAction(
                      icon: AppIcons.share,
                      tooltip: 'Paylaş',
                    ),
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '02',
            name: 'BottomNav',
            spec:
                'h 56 + alt safe area · ikon 24 + navLabel · üst 1 pt border · '
                'push ekranlarda gizli',
            variants: [
              _Variant(
                'aktif sekme değiştirilebilir',
                AppBottomNav(
                  current: _navTab,
                  onSelected: (tab) => setState(() => _navTab = tab),
                ),
              ),
            ],
          ),

          _Section(
            number: '03',
            name: 'FilterChipRow',
            spec: 'h 32 · padding 14 · gap 8 · aktif primary, pasif surfaceAlt',
            variants: [
              _Variant(
                'default · aktif ilk',
                FilterChipRow(
                  labels: const [
                    'Tümü',
                    'Devam Eden',
                    'Yaklaşan',
                    'Tamamlanan',
                  ],
                  selectedIndex: _filterIndex,
                  onSelected: (index) => setState(() => _filterIndex = index),
                  padding: EdgeInsets.zero,
                ),
              ),
              _Variant(
                'disabled (%40 opak)',
                const Row(
                  children: [
                    AppFilterChip(
                      label: 'Doluluk',
                      selected: false,
                      enabled: false,
                    ),
                    SizedBox(width: AppSpace.chipGap),
                    AppFilterChip(
                      label: 'Firmalar',
                      selected: false,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            number: '04',
            name: 'DropdownChip',
            spec: 'h 28 · surfaceAlt · caption Medium + chevron 14 · '
                'basınca bottom sheet',
            variants: [
              _Variant(
                'kart başlığının sağına hizalı',
                Row(
                  children: [
                    Expanded(
                      child: Text('Genel Bakış', style: AppTypography.titleM),
                    ),
                    DropdownChip(
                      label: _period,
                      sheetTitle: 'Dönem',
                      options: const ['Bugün', 'Bu Hafta', 'Bu Ay', 'Tümü'],
                      onSelected: (value) => setState(() => _period = value),
                    ),
                  ],
                ),
              ),
              _Variant(
                'uzun etiket varyantları',
                const Wrap(
                  spacing: AppSpace.chipGap,
                  runSpacing: AppSpace.chipGap,
                  children: [
                    DropdownChip(
                      label: '7 Gün',
                      options: ['7 Gün', '30 Gün'],
                      onSelected: _noop,
                    ),
                    DropdownChip(
                      label: 'Mayıs 2026',
                      options: ['Mayıs 2026', 'Nisan 2026'],
                      onSelected: _noop,
                    ),
                    DropdownChip(
                      label: '01 Mayıs - 15 Mayıs 2026',
                      options: ['01 Mayıs - 15 Mayıs 2026'],
                      onSelected: _noop,
                    ),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            number: '05',
            name: 'KpiCard',
            spec:
                'h ~88 · ikon konteyneri 32×32 r10 tint · caption etiket · '
                'numL değer · 2×2 grid gap 12',
            variants: [
              _Variant(
                '4 renk varyantı',
                KpiGrid(
                  cards: [
                    KpiCard(
                      icon: AppIcons.totalEvents,
                      color: AppColors.primary,
                      label: 'Toplam Etkinlik',
                      value: Tr.number(28),
                    ),
                    KpiCard(
                      icon: AppIcons.totalSold,
                      color: AppColors.info,
                      label: 'Toplam Satılan',
                      value: Tr.number(12842),
                    ),
                    KpiCard(
                      icon: AppIcons.revenue,
                      color: AppColors.success,
                      label: 'Toplam Gelir',
                      value: Tr.currency(12842600),
                    ),
                    KpiCard(
                      icon: AppIcons.occupancy,
                      color: AppColors.purple,
                      label: 'Ortalama Doluluk',
                      value: Tr.percent(68.4),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            number: '06 · 07',
            name: 'SectionCard · DonutChart',
            spec:
                'donut çap 120 · kalınlık 24 · segment aralığı 2 · '
                'merkez numM + micro · legend nokta 8',
            variants: [
              _Variant(
                'başlıklı kart + donut',
                SectionCard(
                  title: 'Satış Dağılımı (Tüm Etkinlikler)',
                  child: VendorDonutChart(
                    shares: MockFixtures.vendorBreakdown,
                    centerValue: 12842,
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '08',
            name: 'MiniStatCell',
            spec:
                'surfaceAlt r12 padding 10 · micro etiket + 17 SemiBold '
                'success değer · 4\'lü eşit grid gap 8',
            variants: [
              _Variant(
                'Günlük Satış Özeti kartı içinde',
                SectionCard(
                  title: 'Günlük Satış Özeti',
                  trailing: const DropdownChip(
                    label: '7 Gün',
                    options: ['7 Gün', '30 Gün'],
                    onSelected: _noop,
                  ),
                  child: MiniStatRow(
                    cells: [
                      MiniStatCell(
                        label: 'Dün',
                        icon: AppIcons.clock,
                        value: Tr.signedNumber(444),
                      ),
                      MiniStatCell(
                        label: 'Bugün',
                        value: Tr.signedNumber(529),
                      ),
                      MiniStatCell(
                        label: 'Son 7 Gün',
                        value: Tr.signedNumber(2846),
                      ),
                      MiniStatCell(
                        label: 'Günlük Ort.',
                        value: Tr.signedNumber(407),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '09 · 10 · 22',
            name: 'EventListCard · StatusText · PosterPlaceholder',
            spec:
                'padding 12 · afiş 76×76 r10 · alt 4 pt progress = accentColor '
                '· tüm kart tıklanabilir',
            variants: [
              _Variant(
                'üç durum — Devam Eden · Yaklaşan · Tamamlanan',
                Column(
                  children: [
                    for (final id in const [
                      'cgh2',
                      'meksika-acmazi',
                      'gece-yarisi-kabare',
                    ]) ...[
                      EventListCard(
                        event: MockFixtures.events.firstWhere(
                          (event) => event.id == id,
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpace.cardGap),
                    ],
                  ],
                ),
              ),
              _Variant(
                'StatusChip (detay) · h 24 padding 10 tint',
                const Wrap(
                  spacing: AppSpace.chipGap,
                  runSpacing: AppSpace.chipGap,
                  children: [
                    StatusChip(status: EventStatus.devamEden),
                    StatusChip(status: EventStatus.yaklasan),
                    StatusChip(status: EventStatus.tamamlanan),
                  ],
                ),
              ),
              _Variant(
                'doluluk değişim rozeti — ya tüm kartlarda ya hiç',
                const Wrap(
                  spacing: AppSpace.chipGap,
                  children: [DeltaBadge(delta: 3), DeltaBadge(delta: -2)],
                ),
              ),
              _Variant(
                'PosterPlaceholder · 76 liste / 96 detay',
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PosterPlaceholder.list(initials: 'DD'),
                    SizedBox(width: AppSpace.cardGap),
                    PosterPlaceholder.detail(initials: 'ÇGH'),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            number: '11 · 12 · 13',
            name: 'EventHeader · StatTrio · LabeledProgress',
            spec: 'detay ekranı üst bloğu · doluluk barı 6 pt',
            variants: [
              _Variant('EventHeader', EventHeader(show: _show, onPickShow: () {})),
              _Variant(
                'StatTrio + LabeledProgress',
                SectionCard(
                  child: Column(
                    children: [
                      StatTrio(
                        items: [
                          StatTrioItem(
                            label: 'Kapasite',
                            value: Tr.number(_show.capacity),
                          ),
                          StatTrioItem(
                            label: 'Satılan',
                            value: Tr.number(_show.sold),
                            color: AppColors.success,
                          ),
                          StatTrioItem(
                            label: 'Kalan',
                            value: Tr.number(_show.remaining),
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.cardPadding),
                      const Divider(),
                      const SizedBox(height: AppSpace.cardPadding),
                      LabeledProgress(
                        label: 'Doluluk Oranı',
                        valueText: Tr.percent(_show.occupancyPct),
                        value: _show.occupancyPct,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '14',
            name: 'VendorBarList',
            spec:
                'isim body · değer bodyStrong · yüzde caption sağa dayalı 48 pt '
                '· bar 4 pt vendor rengi · satır arası 12',
            variants: [
              _Variant(
                'firma dağılımı',
                SectionCard(
                  title: 'Biletleme Firmalarına Göre Dağılım',
                  child: VendorBarList(shares: _show.vendorBreakdown),
                ),
              ),
              _Variant(
                'etkinlik bazlı varyant (accentColor)',
                SectionCard(
                  child: AccentBarList(
                    rows: [
                      for (final event in MockFixtures.events.take(4))
                        AccentBarRow(
                          label: event.title,
                          pct: event.occupancyPct,
                          color: event.effectiveAccentColor,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '15',
            name: 'SegmentedTabs',
            spec:
                'aktif primary metin + 2 pt underline · kolaja sadık konum '
                'altta, alternatif header altı',
            variants: [
              _Variant(
                'bottom (varsayılan)',
                SegmentedTabs(
                  labels: const ['Genel Bakış', 'Günlük Satış', 'Detaylar'],
                  selectedIndex: _tabIndex,
                  onSelected: (index) => setState(() => _tabIndex = index),
                ),
              ),
              _Variant(
                'underHeader (alternatif)',
                SegmentedTabs(
                  labels: const ['Genel Bakış', 'Günlük Satış', 'Detaylar'],
                  selectedIndex: _tabIndex,
                  onSelected: (index) => setState(() => _tabIndex = index),
                  placement: SegmentedTabsPlacement.underHeader,
                ),
              ),
            ],
          ),

          _Section(
            number: '16 · 17',
            name: 'HeroNumber · LineChart',
            spec:
                'çizgi 2 pt success · nokta 6 pt · nokta üstünde micro değer · '
                'yatay kesikli grid',
            variants: [
              const _Variant(
                'HeroNumber',
                HeroNumber(
                  label: 'Son 7 Gün Toplam',
                  value: 2846,
                  unit: 'bilet',
                  trendPct: 18.6,
                  trendNote: '(Önceki 7 güne göre)',
                ),
              ),
              _Variant(
                'LineChart · 7 gün, nokta etiketli',
                SectionCard(
                  child: SalesLineChart(series: MockFixtures.dailySales),
                ),
              ),
              _Variant(
                'LineChart · nokta etiketleri gizli (30/90 gün varyantı)',
                SectionCard(
                  child: SalesLineChart(
                    series: MockFixtures.dailySales,
                    showPointLabels: false,
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '18 · 19',
            name: 'BarChart · DataRowList',
            spec:
                'bar genişlik 32 üst r4 info · veri yoksa "–" · '
                'satır h 44 · 1 pt divider',
            variants: [
              _Variant(
                'Aylık Satış Trendi',
                SectionCard(
                  title: 'Aylık Satış Trendi',
                  trailing: const DropdownChip(
                    label: 'Mayıs 2026',
                    options: ['Mayıs 2026'],
                    onSelected: _noop,
                  ),
                  child: SalesBarChart(buckets: MockFixtures.mayBuckets),
                ),
              ),
              _Variant(
                'Günlük Satış Rakamları',
                SectionCard(
                  title: 'Günlük Satış Rakamları',
                  child: DataRowList(
                    rows: [
                      for (final point in MockFixtures.dailySales.reversed)
                        DataRowItem(
                          label: Tr.date(point.date),
                          value: Tr.number(point.sold),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _Section(
            number: '20 · 21',
            name: 'CalendarMonth · DayEventRow',
            spec:
                'hücre 40×40 · seçili primary dolu daire · bugün 1,5 pt halka '
                '· etkinlikli günde 4 pt nokta · saat kutusu 52×32',
            variants: [
              _Variant(
                'Mayıs 2026 · 15 seçili, 13 bugün',
                SectionCard(
                  child: CalendarMonth(
                    month: _calendarMonth,
                    selectedDate: _selectedDay,
                    today: DateTime(2026, 5, 13),
                    eventDays: MockFixtures.mayEventDays,
                    onSelectDate: (date) =>
                        setState(() => _selectedDay = date),
                    onMonthChanged: (month) =>
                        setState(() => _calendarMonth = month),
                  ),
                ),
              ),
              _Variant(
                'DayEventRow · satır arası 8',
                Column(
                  children: [
                    for (final show in MockFixtures.shows.take(3)) ...[
                      DayEventRow(show: show, onTap: () {}),
                      const SizedBox(height: AppSpace.chipGap),
                    ],
                  ],
                ),
              ),
            ],
          ),

          _Section(
            number: '23',
            name: 'EmptyState · Skeleton · ErrorState · OfflineBanner',
            spec: 'shimmer surfaceAlt üzerinde · offline banner warning tint',
            variants: [
              _Variant(
                'EmptyState',
                SectionCard(
                  padding: EdgeInsets.zero,
                  child: EmptyState(
                    message: 'Bu filtreye uyan etkinlik yok',
                    actionLabel: 'Filtreyi temizle',
                    onAction: () {},
                  ),
                ),
              ),
              _Variant(
                'ErrorState',
                SectionCard(
                  padding: EdgeInsets.zero,
                  child: ErrorState(onRetry: () {}),
                ),
              ),
              const _Variant('Skeleton · kart şekilli shimmer', Column(
                children: [
                  EventCardSkeleton(),
                  SizedBox(height: AppSpace.cardGap),
                  CardSkeleton(),
                ],
              )),
              _Variant(
                'OfflineBanner + son güncelleme damgası',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OfflineBanner(),
                    const SizedBox(height: AppSpace.chipGap),
                    Text(
                      'Son güncelleme ${Tr.shortStamp(MockFixtures.overview.updatedAt)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            number: '+',
            name: 'Destek bileşenleri',
            spec:
                'ekranların ihtiyaç duyduğu, kolajda ayrı numarası olmayan '
                'bileşenler',
            variants: [
              _Variant(
                'SearchField (09_Arama)',
                SearchField(
                  controller: _searchController,
                  onChanged: (_) {},
                ),
              ),
              _Variant(
                'SettingsGroup · SettingsRow (07_Ayarlar)',
                SettingsGroup(
                  title: 'Veri kaynakları',
                  rows: [
                    SettingsRow(
                      label: 'Biletix',
                      detail: 'Son eşitleme 15 May 20:31',
                      leadingColor: AppColors.success,
                      value: 'Bağlı',
                      onTap: () {},
                    ),
                    SettingsRow(
                      label: 'Diğer',
                      detail: 'Bağlı değil',
                      leadingColor: AppColors.textTertiary,
                      value: 'Bağla',
                      onTap: () {},
                    ),
                    SettingsRow(
                      label: 'Günlük satış özeti',
                      detail: 'Her gün belirlenen saatte gönderilir',
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                  ],
                ),
              ),
              _Variant(
                'NotificationRow (08_Bildirimler) · okunmamış + okunmuş',
                Column(
                  children: [
                    for (final notification
                        in MockFixtures.notifications.take(3)) ...[
                      NotificationRow(notification: notification),
                      const SizedBox(height: AppSpace.chipGap),
                    ],
                  ],
                ),
              ),
              _Variant(
                'VendorLineChart (15_Raporlar_Firmalar)',
                SectionCard(
                  title: 'Firma Bazlı Günlük Satış',
                  child: VendorLineChart(series: _vendorSeries),
                ),
              ),
              _Variant(
                'AppDrawer (10_Drawer)',
                SizedBox(
                  height: 420,
                  child: AppDrawer(
                    current: _navTab,
                    onSelect: (tab) => setState(() => _navTab = tab),
                    version: '0.1.0 (1)',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _noop(String _) {}
}

/// Galeri bölümü — numara, ad ve HTML'deki ölçü notu başlıkta.
class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.name,
    required this.spec,
    required this.variants,
  });

  final String number;
  final String name;
  final String spec;
  final List<_Variant> variants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sectionGap * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      number,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppSpace.cardGap),
                    Expanded(child: Text(name, style: AppTypography.titleM)),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                Text(spec, style: AppTypography.caption),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: AppSpace.cardPadding),
          for (final (index, variant) in variants.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpace.sectionGap),
            Text(
              variant.label,
              style: AppTypography.micro.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpace.chipGap),
            variant.child,
          ],
        ],
      ),
    );
  }
}

class _Variant {
  const _Variant(this.label, this.child);

  final String label;
  final Widget child;
}

/// App bar / bottom nav gibi tam genişlik bileşenleri çerçeveler.
class _BarFrame extends StatelessWidget {
  const _BarFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cellR,
        border: Border.all(
          color: AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: ClipRRect(borderRadius: AppRadius.cellR, child: child),
    );
  }
}
