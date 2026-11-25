import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_tile.dart';
import '../widgets/state_message.dart';
import '../widgets/weather_details.dart';
import 'search_screen.dart';

/// Home / Weather Screen.
/// Menampilkan header gradien biru lembut dengan search bar pill,
/// kondisi cuaca terkini, suhu, detail cuaca pastel, dan perkiraan 7 hari.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            children: [
              _HomeHeader(
                vm: vm,
                onSearchTap: () => _openSearch(context),
              ),
              Expanded(child: _buildBody(context, vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.state) {
      case ViewState.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppPalette.primaryBlue),
        );

      case ViewState.empty:
        return StateMessage(
          icon: Icons.travel_explore_rounded,
          title: 'Belum ada lokasi',
          message: 'Cari nama kota untuk melihat informasi cuaca terkini.',
          actionLabel: 'Cari Kota',
          onAction: () => _openSearch(context),
        );

      case ViewState.error:
        return StateMessage(
          icon: Icons.cloud_off_rounded,
          title: 'Gagal memuat cuaca',
          message: vm.errorMessage,
          actionLabel: 'Coba Lagi',
          onAction: vm.refresh,
        );

      case ViewState.success:
        return _buildContent(context, vm);
    }
  }

  Widget _buildContent(BuildContext context, WeatherViewModel vm) {
    final weather = vm.weather!;
    final location = vm.location!;
    final theme = Theme.of(context);

    return RefreshIndicator(
      color: AppPalette.primaryBlue,
      onRefresh: vm.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          // Konten dibatasi lebarnya agar tetap rapi di layar lebar/tablet.
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrentWeatherCard(
                    location: location,
                    weather: weather,
                    onRefresh: vm.refresh,
                  ),
                  const SizedBox(height: 22),
                  Text('Detail Cuaca', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  WeatherDetails(weather: weather),
                  const SizedBox(height: 24),
                  Text(
                    'Perkiraan ${weather.daily.length} Hari ke Depan',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < weather.daily.length; i++) ...[
                    ForecastTile(
                      forecast: weather.daily[i],
                      isToday: i == 0,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header gradien biru lembut dengan tombol bulat putih & search bar pill.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.vm,
    required this.onSearchTap,
  });

  final WeatherViewModel vm;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = vm.location;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [
                  Color(0xFF1F3B73),
                  Color(0xFF162444),
                  Color(0xFF121C33),
                ]
              : const [
                  Color(0xFF9AC3FF),
                  Color(0xFFD5E6FF),
                  Color(0xFFEDF4FF),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Badge ikon aplikasi bulat di kiri atas.
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppPalette.skyAccent,
                              AppPalette.primaryBlue,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.7),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      if (location != null)
                        Consumer<SearchViewModel>(
                          builder: (context, searchVm, _) {
                            final fav = searchVm.isFavorite(location);
                            return _CircleIconButton(
                              tooltip: fav
                                  ? 'Hapus dari favorit'
                                  : 'Simpan ke favorit',
                              icon: fav
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              iconColor: fav ? AppPalette.amberIcon : null,
                              onTap: () => searchVm.toggleFavorite(location),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    location != null
                        ? location.name
                        : 'Cuaca Hari Ini,\nSiap Cek Lokasi?',
                    style: theme.textTheme.headlineMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location != null && location.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      location.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFFB5C7E8)
                            : const Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Search bar pill putih melayang (tap untuk ke SearchScreen).
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSearchTap,
                      borderRadius: BorderRadius.circular(30),
                      child: Ink(
                        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppPalette.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: AppPalette.primaryBlue
                                    .withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? Colors.white70
                                  : AppPalette.textDark,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cari nama kota...',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppPalette.scaffoldLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.travel_explore_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white70
                                    : AppPalette.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? AppPalette.cardDark : Colors.white,
        shape: const CircleBorder(),
        elevation: isDark ? 0 : 2,
        shadowColor: AppPalette.primaryBlue.withValues(alpha: 0.16),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: iconColor ??
                  (isDark ? Colors.white : AppPalette.textDark),
            ),
          ),
        ),
      ),
    );
  }
}
