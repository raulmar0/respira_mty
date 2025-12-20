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
  final List<Map<String, dynamic>>? parametrosAlerta;
  final List<Map<String, dynamic>>? parametrosUI;

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
    this.parametrosAlerta,
    this.parametrosUI,
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

  /// Obtiene la lista de contaminantes desde parametrosUI
  List<Map<String, dynamic>> get pollutantsFromUI {
    if (parametrosUI == null) return [];
    return parametrosUI!.map((param) {
      final rawParam = (param['Parameter'] as String?)?.trim() ?? '';
      final hrAveData = param['HrAveData'];

      // Handle ND / not detected
      double? value;
      if (hrAveData is num) {
        value = hrAveData.toDouble();
      } else if (hrAveData is String) {
        if (hrAveData.toUpperCase() == 'ND') {
          value = null;
        } else {
          value = double.tryParse(hrAveData);
        }
      }

      // Normalize parameter names and units
      String parameter;
      String label;
      String unit;

      switch (rawParam.toUpperCase()) {
        case 'PM10_12':
        case 'PM10M':
        case 'PM10':
          parameter = 'PM10';
          label = 'PM10';
          unit = 'µg/m³';
          break;
        case 'PM25_12':
        case 'PM25M':
        case 'PM2.5':
        case 'PM25':
          parameter = 'PM25';
          label = 'PM2.5';
          unit = 'µg/m³';
          break;
        case 'O3M':
        case 'O3':
          parameter = 'O3';
          label = 'O3';
          unit = 'ppb';
          break;
        case 'NO2M':
        case 'NO2':
          parameter = 'NO2';
          label = 'NO2';
          unit = 'ppb';
          break;
        case 'SO2_1':
        case 'SO2M':
        case 'SO2':
          parameter = 'SO2';
          label = 'SO2';
          unit = 'ppb';
          break;
        case 'CO8M':
        case 'COM':
        case 'CO':
          parameter = 'CO';
          label = 'CO';
          unit = 'ppm';
          break;
        default:
          parameter = rawParam;
          label = (param['ParameterLargo'] as String?) ?? rawParam;
          unit = AirQualityScale.getUnitForParameter(rawParam);
      }

      return {
        'parameter': parameter,
        'value': value, // null means N/D
        'label': label,
        'unit': unit,
      };
    }).toList();
  }
}
