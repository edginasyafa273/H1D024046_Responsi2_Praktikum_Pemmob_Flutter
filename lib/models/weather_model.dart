/// Data cuaca saat ini (field `current` dari Forecast API).
class CurrentWeather {
  final DateTime time;
  final double temperature; // current.temperature_2m
  final int humidity; // current.relative_humidity_2m
  final double apparentTemperature; // current.apparent_temperature
  final double precipitation; // current.precipitation
  final int weatherCode; // current.weather_code
  final double windSpeed; // current.wind_speed_10m

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Perkiraan cuaca untuk satu hari (field `daily` dari Forecast API).
class DailyForecast {
  final DateTime date;
  final int weatherCode; // daily.weather_code
  final double temperatureMax; // daily.temperature_2m_max
  final double temperatureMin; // daily.temperature_2m_min
  final int precipitationProbabilityMax; // daily.precipitation_probability_max

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
  });
}

/// Gabungan cuaca saat ini dan perkiraan harian.
class WeatherModel {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String timezone;

  const WeatherModel({
    required this.current,
    required this.daily,
    required this.timezone,
  });

  /// Mengolah respons JSON Forecast API menjadi model Dart.
  /// Pada `daily`, API mengirim data berbentuk array per field,
  /// sehingga perlu digabung per indeks menjadi daftar [DailyForecast].
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = CurrentWeather.fromJson(
      json['current'] as Map<String, dynamic>,
    );

    final d = json['daily'] as Map<String, dynamic>;
    final dates = (d['time'] as List).cast<String>();
    final codes = d['weather_code'] as List;
    final maxTemps = d['temperature_2m_max'] as List;
    final minTemps = d['temperature_2m_min'] as List;
    final rainProbs = d['precipitation_probability_max'] as List;

    final daily = List<DailyForecast>.generate(dates.length, (i) {
      return DailyForecast(
        date: DateTime.parse(dates[i]),
        weatherCode: (codes[i] as num?)?.toInt() ?? 0,
        temperatureMax: (maxTemps[i] as num?)?.toDouble() ?? 0,
        temperatureMin: (minTemps[i] as num?)?.toDouble() ?? 0,
        precipitationProbabilityMax: (rainProbs[i] as num?)?.toInt() ?? 0,
      );
    });

    return WeatherModel(
      current: current,
      daily: daily,
      timezone: (json['timezone'] ?? '') as String,
    );
  }
}
