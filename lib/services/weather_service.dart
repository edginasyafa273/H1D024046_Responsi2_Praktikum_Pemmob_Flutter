import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Error yang pesannya sudah siap ditampilkan ke pengguna.
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}

/// Service networking: semua HTTP Request (metode GET) ke Open-Meteo.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _geocodingHost = 'geocoding-api.open-meteo.com';
  static const _forecastHost = 'api.open-meteo.com';
  static const _timeout = Duration(seconds: 15);

  /// GET https://geocoding-api.open-meteo.com/v1/search?name=...
  /// Mengembalikan list kosong jika kota tidak ditemukan.
  Future<List<LocationModel>> searchLocations(String name) async {
    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': name,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final json = await _get(uri);
    final results = json['results'];
    if (results == null) return [];

    try {
      return (results as List)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const WeatherException('Format data lokasi tidak valid.');
    }
  }

  /// GET https://api.open-meteo.com/v1/forecast
  /// Parameter: latitude, longitude, current, daily, timezone=auto.
  Future<WeatherModel> fetchWeather(LocationModel location) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final json = await _get(uri);

    try {
      return WeatherModel.fromJson(json);
    } catch (_) {
      throw const WeatherException('Format data cuaca tidak valid.');
    }
  }

  /// Menjalankan GET dan mengubah body menjadi Map JSON.
  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherException(
          'Server mengembalikan kesalahan (kode ${response.statusCode}).',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw const WeatherException(
        'Tidak ada koneksi internet. Periksa jaringanmu lalu coba lagi.',
      );
    } on TimeoutException {
      throw const WeatherException(
        'Permintaan terlalu lama. Coba lagi beberapa saat.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Gagal terhubung ke server. Periksa koneksi internetmu.',
      );
    } on FormatException {
      throw const WeatherException('Respons server tidak dapat dibaca.');
    }
  }
}
