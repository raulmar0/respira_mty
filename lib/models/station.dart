class Station {
  final String id;
  final String apiCode;
  final String name;
  final String status;
  final int aqi;
  final double pm25;
  final double pm10;
  final double o3;
  final double no2;
  final double so2;
  final double co;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final DateTime? updatedAt;

  const Station({
    required this.id,
    required this.apiCode,
    required this.name,
    required this.status,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.no2,
    required this.so2,
    required this.co,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.updatedAt,
  });
}
