/// Model lokasi hasil Geocoding API Open-Meteo.
/// Juga dipakai untuk data favorit, riwayat, dan lokasi terakhir
/// (disimpan sebagai JSON di SharedPreferences).
class LocationModel {
  final int id;
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;
  final String? timezone;

  const LocationModel({
    required this.id,
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.timezone,
  });

  /// Mengolah JSON dari Geocoding API menjadi model Dart.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      admin1: json['admin1'] as String?,
      country: (json['country'] ?? '') as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
      };

  /// Contoh: "Jawa Tengah, Indonesia".
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  /// Kunci unik berdasarkan koordinat, dipakai untuk membandingkan lokasi.
  String get key =>
      '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

  @override
  bool operator ==(Object other) =>
      other is LocationModel && other.key == key;

  @override
  int get hashCode => key.hashCode;
}
