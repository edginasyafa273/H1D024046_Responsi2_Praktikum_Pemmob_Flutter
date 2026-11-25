import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/weather_code.dart';

void main() {
  test('WeatherModel.fromJson mengolah respons Open-Meteo', () {
    final json = {
      'timezone': 'Asia/Jakarta',
      'current': {
        'time': '2026-11-25T14:00',
        'temperature_2m': 30.5,
        'relative_humidity_2m': 70,
        'apparent_temperature': 34.1,
        'precipitation': 0.2,
        'weather_code': 61,
        'wind_speed_10m': 8.4,
      },
      'daily': {
        'time': ['2026-11-25', '2026-11-26'],
        'weather_code': [61, 3],
        'temperature_2m_max': [31.0, 32.0],
        'temperature_2m_min': [23.0, 24.0],
        'precipitation_probability_max': [80, 40],
      },
    };

    final model = WeatherModel.fromJson(json);

    expect(model.current.temperature, 30.5);
    expect(model.current.humidity, 70);
    expect(model.daily.length, 2);
    expect(model.daily.first.precipitationProbabilityMax, 80);
    expect(model.daily.last.temperatureMax, 32.0);
  });

  test('weatherConditionFromCode memetakan kode WMO', () {
    expect(weatherConditionFromCode(0).description, 'Cerah');
    expect(weatherConditionFromCode(95).description, 'Badai petir');
  });
}
