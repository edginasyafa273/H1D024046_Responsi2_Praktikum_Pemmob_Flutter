import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service Local Storage (SharedPreferences).
/// Menyimpan lokasi favorit, riwayat pencarian, dan lokasi terakhir dipilih
/// sebagai JSON, sehingga datanya tampil kembali saat aplikasi dibuka.
class StorageService {
  static const _favoritesKey = 'favorite_locations';
  static const _historyKey = 'search_history';
  static const _lastLocationKey = 'last_location';

  static const maxHistory = 10;

  Future<List<LocationModel>> getFavorites() => _readList(_favoritesKey);

  Future<void> saveFavorites(List<LocationModel> items) =>
      _writeList(_favoritesKey, items);

  Future<List<LocationModel>> getHistory() => _readList(_historyKey);

  Future<void> saveHistory(List<LocationModel> items) =>
      _writeList(_historyKey, items);

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null) return null;
    try {
      return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  Future<List<LocationModel>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(key) ?? [];
    final result = <LocationModel>[];
    for (final raw in rawList) {
      try {
        result.add(
          LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // Data rusak dilewati supaya aplikasi tidak crash.
      }
    }
    return result;
  }

  Future<void> _writeList(String key, List<LocationModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
