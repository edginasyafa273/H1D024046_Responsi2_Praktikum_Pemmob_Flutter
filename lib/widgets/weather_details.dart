import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color badgeBg;
  final Color iconColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.badgeBg,
    required this.iconColor,
  });
}

/// Informasi tambahan: suhu yang dirasakan, kelembapan, kecepatan angin,
/// curah hujan, kemungkinan hujan, serta suhu maks/min hari ini.
/// Menggunakan badge pastel lembut & jumlah kolom menyesuaikan lebar layar.
class WeatherDetails extends StatelessWidget {
  const WeatherDetails({super.key, required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    final items = <_DetailItem>[
      _DetailItem(
        icon: Icons.water_drop_rounded,
        label: 'Kelembapan',
        value: '${current.humidity}%',
        badgeBg: AppPalette.blueSoft,
        iconColor: AppPalette.blueIcon,
      ),
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Kecepatan angin',
        value: '${current.windSpeed.toStringAsFixed(1)} km/j',
        badgeBg: AppPalette.greenSoft,
        iconColor: AppPalette.greenIcon,
      ),
      _DetailItem(
        icon: Icons.umbrella_rounded,
        label: 'Peluang hujan',
        value: today == null ? '-' : '${today.precipitationProbabilityMax}%',
        badgeBg: AppPalette.purpleSoft,
        iconColor: AppPalette.purpleIcon,
      ),
      _DetailItem(
        icon: Icons.thermostat_rounded,
        label: 'Terasa seperti',
        value: '${current.apparentTemperature.round()}°C',
        badgeBg: AppPalette.amberSoft,
        iconColor: AppPalette.amberIcon,
      ),
      _DetailItem(
        icon: Icons.grain_rounded,
        label: 'Curah hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
        badgeBg: AppPalette.cyanSoft,
        iconColor: AppPalette.cyanIcon,
      ),
      _DetailItem(
        icon: Icons.swap_vert_rounded,
        label: 'Maks / Min',
        value: today == null
            ? '-'
            : '${today.temperatureMax.round()}° / ${today.temperatureMin.round()}°',
        badgeBg: AppPalette.roseSoft,
        iconColor: AppPalette.roseIcon,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 480 ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _DetailTile(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.item});

  final _DetailItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: AppTheme.cardDecoration(context, radius: 22),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? item.iconColor.withValues(alpha: 0.18)
                  : item.badgeBg,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
