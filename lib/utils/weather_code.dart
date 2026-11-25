import 'package:flutter/material.dart';

/// Deskripsi dan ikon untuk satu kode cuaca WMO (`weather_code`).
class WeatherCondition {
  final String description;
  final IconData icon;

  const WeatherCondition(this.description, this.icon);
}

/// Mengubah kode cuaca WMO dari Open-Meteo menjadi teks dan ikon.
WeatherCondition weatherConditionFromCode(int code) {
  switch (code) {
    case 0:
      return const WeatherCondition('Cerah', Icons.wb_sunny);
    case 1:
      return const WeatherCondition('Cerah berawan', Icons.wb_sunny_outlined);
    case 2:
      return const WeatherCondition('Berawan sebagian', Icons.wb_cloudy);
    case 3:
      return const WeatherCondition('Mendung', Icons.cloud);
    case 45:
    case 48:
      return const WeatherCondition('Berkabut', Icons.foggy);
    case 51:
    case 53:
    case 55:
      return const WeatherCondition('Gerimis', Icons.grain);
    case 56:
    case 57:
      return const WeatherCondition('Gerimis beku', Icons.grain);
    case 61:
      return const WeatherCondition('Hujan ringan', Icons.water_drop_outlined);
    case 63:
      return const WeatherCondition('Hujan sedang', Icons.water_drop);
    case 65:
      return const WeatherCondition('Hujan lebat', Icons.water_drop);
    case 66:
    case 67:
      return const WeatherCondition('Hujan beku', Icons.ac_unit);
    case 71:
    case 73:
    case 75:
      return const WeatherCondition('Salju', Icons.ac_unit);
    case 77:
      return const WeatherCondition('Butiran salju', Icons.ac_unit);
    case 80:
    case 81:
      return const WeatherCondition('Hujan lokal', Icons.water_drop);
    case 82:
      return const WeatherCondition('Hujan lokal lebat', Icons.water_drop);
    case 85:
    case 86:
      return const WeatherCondition('Hujan salju lokal', Icons.ac_unit);
    case 95:
      return const WeatherCondition('Badai petir', Icons.thunderstorm);
    case 96:
    case 99:
      return const WeatherCondition(
        'Badai petir dan hujan es',
        Icons.thunderstorm,
      );
    default:
      return const WeatherCondition('Tidak diketahui', Icons.help_outline);
  }
}
