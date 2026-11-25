import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/weather_code.dart';

/// Satu baris perkiraan cuaca harian: hari, kondisi, suhu maks/min,
/// dan peluang hujan maksimum dalam kartu putih lembut.
class ForecastTile extends StatelessWidget {
  const ForecastTile({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  final DailyForecast forecast;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final condition = weatherConditionFromCode(forecast.weatherCode);
    final dayLabel = isToday
        ? 'Hari ini'
        : DateFormat('EEEE, d MMM', 'id_ID').format(forecast.date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardDecoration(context, radius: 22),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? AppPalette.primaryBlue.withValues(alpha: 0.18)
                  : AppPalette.blueSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              condition.icon,
              size: 22,
              color: AppPalette.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  condition.description,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${forecast.temperatureMax.round()}° / '
                '${forecast.temperatureMin.round()}°',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppPalette.primaryBlue.withValues(alpha: 0.18)
                      : AppPalette.blueSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Hujan ${forecast.precipitationProbabilityMax}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
