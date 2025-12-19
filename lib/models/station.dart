import '../utils/air_quality_scale.dart';

class Station {
  final String id;
  final String apiCode;
  final String name;
  final double? pm25;
  final double? pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final DateTime? updatedAt;

  const Station({
    required this.id,
    required this.apiCode,
    required this.name,
    this.pm25,
    this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.updatedAt,
  });

  /// Calcula el contaminante dominante y obtiene color/estado
  DominantPollutant get dominantPollutant => AirQualityScale.calculateDominant(
    pm25: pm25,
    pm10: pm10,
    o3: o3,
    no2: no2,
    so2: so2,
    co: co,
  );

  /// Obtiene el estado de la estación basado en el contaminante dominante
  String get status => dominantPollutant.status;

  /// Obtiene el AQI equivalente (índice de categoría 0-5 para compatibilidad)
  int get aqi => dominantPollutant.category.index * 50;
}
