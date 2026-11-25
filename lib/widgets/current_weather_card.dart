import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/weather_code.dart';

/// Kartu utama Home: banner status gradien biru lembut + kartu putih utama
/// berisi kondisi cuaca terkini, suhu saat ini, dan ringkasan harian.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.weather,
    this.onRefresh,
  });

  final LocationModel location;
  final WeatherModel weather;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final current = weather.current;
    final condition = weatherConditionFromCode(current.weatherCode);
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;
    final updatedTime = DateFormat('HH:mm').format(current.time);

    return Column(
      children: [
        // Banner pill gradien biru (terinspirasi dari status pill referensi).
        InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isDark
                    ? const [
                        Color(0xFF1F3B73),
                        Color(0xFF233252),
                        Color(0xFF1E3768),
                      ]
                    : const [
                        Color(0xFF9AC2FF),
                        Color(0xFFE4EEFF),
                        Color(0xFFB4D3FF),
                      ],
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: AppPalette.primaryBlue.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppPalette.cardDark : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    condition.icon,
                    color: AppPalette.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${condition.description} • Diperbarui $updatedTime',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppPalette.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: isDark
                        ? AppPalette.skyAccent
                        : AppPalette.deepBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Kartu hero putih bersih dengan suhu besar dan badge pill biru.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: AppTheme.cardDecoration(context, radius: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition.description,
                          style: theme.textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 15,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location.subtitle.isEmpty
                                    ? location.name
                                    : '${location.name}, ${location.subtitle}',
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (today != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Maks ${today.temperatureMax.round()}° • '
                            'Min ${today.temperatureMin.round()}°',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ilustrasi badge ikon cuaca bergaya lembut di kanan atas.
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppPalette.skyAccent,
                          AppPalette.primaryBlue,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppPalette.primaryBlue.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      condition.icon,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${current.temperature.round()}°C',
                        style: theme.textTheme.displayLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.primaryBlue,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppPalette.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Terasa ${current.apparentTemperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
