import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// Status tampilan Home: data kosong, loading, sukses, atau error.
enum ViewState { empty, loading, success, error }

/// ViewModel untuk Home / Weather Screen.
/// View hanya membaca state di sini; request API dilakukan lewat service.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._service, this._storage);

  final WeatherService _service;
  final StorageService _storage;

  ViewState _state = ViewState.loading;
  LocationModel? _location;
  WeatherModel? _weather;
  String _errorMessage = '';
  int _requestId = 0;

  ViewState get state => _state;
  LocationModel? get location => _location;
  WeatherModel? get weather => _weather;
  String get errorMessage => _errorMessage;

  /// Dipanggil saat aplikasi dibuka: memuat lokasi terakhir dari local
  /// storage lalu mengambil cuacanya dari API.
  Future<void> init() async {
    final last = await _storage.getLastLocation();
    if (last == null) {
      _state = ViewState.empty;
      notifyListeners();
      return;
    }
    await loadWeather(last, save: false);
  }

  /// Memilih lokasi lalu mengambil data cuaca dari Open-Meteo.
  Future<void> loadWeather(LocationModel location, {bool save = true}) async {
    final id = ++_requestId;
    _location = location;
    _state = ViewState.loading;
    notifyListeners();

    if (save) {
      await _storage.saveLastLocation(location);
    }

    try {
      final result = await _service.fetchWeather(location);
      if (id != _requestId) return;
      _weather = result;
      _state = ViewState.success;
    } on WeatherException catch (e) {
      if (id != _requestId) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      if (id != _requestId) return;
      _errorMessage = 'Terjadi kesalahan yang tidak diketahui.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Memuat ulang cuaca untuk lokasi yang sedang dipilih.
  Future<void> refresh() async {
    final current = _location;
    if (current == null) return;
    await loadWeather(current, save: false);
  }
}
