import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// Status Search Screen.
/// idle    : belum mencari (tampilkan favorit dan riwayat)
/// loading : sedang request ke Geocoding API
/// success : ada hasil
/// empty   : hasil kosong
/// error   : request gagal
enum SearchStatus { idle, loading, success, empty, error }

/// ViewModel untuk Search / Location Screen.
/// Mengelola pencarian kota, lokasi favorit, dan riwayat pencarian.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._service, this._storage);

  final WeatherService _service;
  final StorageService _storage;

  SearchStatus _status = SearchStatus.idle;
  List<LocationModel> _results = [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _history = [];
  String _errorMessage = '';
  int _requestId = 0;

  SearchStatus get status => _status;
  List<LocationModel> get results => _results;
  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get history => _history;
  String get errorMessage => _errorMessage;

  /// Memuat favorit dan riwayat dari local storage.
  Future<void> loadSaved() async {
    _favorites = await _storage.getFavorites();
    _history = await _storage.getHistory();
    notifyListeners();
  }

  /// Mencari kota berdasarkan nama lewat Geocoding API.
  Future<void> search(String query) async {
    final q = query.trim();
    final id = ++_requestId;

    // Open-Meteo membutuhkan minimal 2 karakter untuk pencarian.
    if (q.length < 2) {
      _results = [];
      _errorMessage = '';
      _status = SearchStatus.idle;
      notifyListeners();
      return;
    }

    _status = SearchStatus.loading;
    notifyListeners();

    try {
      final data = await _service.searchLocations(q);
      if (id != _requestId) return;
      _results = data;
      _status = data.isEmpty ? SearchStatus.empty : SearchStatus.success;
    } on WeatherException catch (e) {
      if (id != _requestId) return;
      _errorMessage = e.message;
      _status = SearchStatus.error;
    } catch (_) {
      if (id != _requestId) return;
      _errorMessage = 'Terjadi kesalahan yang tidak diketahui.';
      _status = SearchStatus.error;
    }
    notifyListeners();
  }

  /// Mengembalikan Search Screen ke kondisi awal.
  void reset() {
    _requestId++;
    _results = [];
    _errorMessage = '';
    _status = SearchStatus.idle;
    notifyListeners();
  }

  bool isFavorite(LocationModel location) => _favorites.contains(location);

  /// Menyimpan atau menghapus lokasi dari favorit.
  Future<void> toggleFavorite(LocationModel location) async {
    if (_favorites.contains(location)) {
      _favorites = _favorites.where((e) => e != location).toList();
    } else {
      _favorites = [location, ..._favorites];
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
  }

  /// Mencatat lokasi yang dipilih ke riwayat (terbaru di atas, maks 10).
  Future<void> addToHistory(LocationModel location) async {
    final updated = [
      location,
      ..._history.where((e) => e != location),
    ];
    _history = updated.take(StorageService.maxHistory).toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storage.saveHistory(_history);
  }
}
