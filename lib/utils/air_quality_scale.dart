import 'package:flutter/material.dart';

/// Categorías de calidad del aire según la tabla del Índice Aire y Salud de NL
enum AirQualityCategory {
  good,        // Buena (verde)
  acceptable,  // Aceptable (amarillo)
  bad,         // Mala (naranja)
  veryBad,     // Muy Mala (rojo)
  extremelyBad,// Extremadamente Mala (morado)
  maintenance, // Mantenimiento (gris) - uno o más parámetros sin datos
}

/// Resultado del cálculo del contaminante dominante
class DominantPollutant {
  final String name;
  final double value;
  final String unit;
  final AirQualityCategory category;
  final bool hasMissingData;

  const DominantPollutant({
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
    this.hasMissingData = false,
  });

  Color get color => AirQualityScale.getColorForCategory(category);
  String get status => AirQualityScale.getStatusForCategory(category);
  
  /// Devuelve el valor formateado para mostrar en el mapa
  String get displayValue {
    if (category == AirQualityCategory.maintenance) return 'N/D';
    if (name == 'CO') return value.toStringAsFixed(1);
    return value.toStringAsFixed(0);
  }
}

class AirQualityScale {
  // Breakpoints según la tabla del Índice Aire y Salud de NL
  // PM10: µg/m³ (promedio móvil de 12 horas)
  static const _thresholdsPM10 = [45.0, 60.0, 132.0, 213.0];
  
  // PM2.5: µg/m³ (promedio móvil de 12 horas)
  static const _thresholdsPM25 = [15.0, 33.0, 79.0, 130.0];
  
  // O3: ppb (promedio de 1 hora) - tabla dice ppm, convertido a ppb (*1000)
  static const _thresholdsO3 = [58.0, 90.0, 135.0, 175.0];
  
  // NO2: ppb (promedio de 1 hora) - tabla dice ppm, convertido a ppb (*1000)
  static const _thresholdsNO2 = [53.0, 106.0, 160.0, 213.0];
  
  // SO2: ppb (promedio de 1 hora) - tabla dice ppm, convertido a ppb (*1000)
  static const _thresholdsSO2 = [35.0, 75.0, 185.0, 304.0];
  
  // CO: ppm (promedio móvil de 8 horas)
  static const _thresholdsCO = [5.0, 9.0, 12.0, 16.0];

  /// Calcula la categoría de un contaminante dado su valor y umbrales
  static AirQualityCategory _getCategoryForValue(double value, List<double> thresholds) {
    if (value <= thresholds[0]) return AirQualityCategory.good;
    if (value <= thresholds[1]) return AirQualityCategory.acceptable;
    if (value <= thresholds[2]) return AirQualityCategory.bad;
    if (value <= thresholds[3]) return AirQualityCategory.veryBad;
    return AirQualityCategory.extremelyBad;
  }

  static AirQualityCategory getCategoryPM10(double val) => _getCategoryForValue(val, _thresholdsPM10);
  static AirQualityCategory getCategoryPM25(double val) => _getCategoryForValue(val, _thresholdsPM25);
  static AirQualityCategory getCategoryO3(double val) => _getCategoryForValue(val, _thresholdsO3);
  static AirQualityCategory getCategoryNO2(double val) => _getCategoryForValue(val, _thresholdsNO2);
  static AirQualityCategory getCategorySO2(double val) => _getCategoryForValue(val, _thresholdsSO2);
  static AirQualityCategory getCategoryCO(double val) => _getCategoryForValue(val, _thresholdsCO);

  /// Calcula el contaminante dominante (el de peor categoría)
  /// Si hay datos faltantes y todos los demás están en verde, devuelve maintenance
  static DominantPollutant calculateDominant({
    double? pm25,
    double? pm10,
    double? o3,
    double? no2,
    double? so2,
    double? co,
  }) {
    final pollutants = <_PollutantData>[];
    bool hasMissing = false;

    if (pm25 != null && pm25 > 0) {
      pollutants.add(_PollutantData('PM2.5', pm25, 'µg/m³', getCategoryPM25(pm25)));
    } else {
      hasMissing = true;
    }

    if (pm10 != null && pm10 > 0) {
      pollutants.add(_PollutantData('PM10', pm10, 'µg/m³', getCategoryPM10(pm10)));
    } else {
      hasMissing = true;
    }

    if (o3 != null && o3 > 0) {
      pollutants.add(_PollutantData('O3', o3, 'ppb', getCategoryO3(o3)));
    } else {
      hasMissing = true;
    }

    if (no2 != null && no2 > 0) {
      pollutants.add(_PollutantData('NO2', no2, 'ppb', getCategoryNO2(no2)));
    } else {
      hasMissing = true;
    }

    if (so2 != null && so2 > 0) {
      pollutants.add(_PollutantData('SO2', so2, 'ppb', getCategorySO2(so2)));
    } else {
      hasMissing = true;
    }

    if (co != null && co > 0) {
      pollutants.add(_PollutantData('CO', co, 'ppm', getCategoryCO(co)));
    } else {
      hasMissing = true;
    }

    // Si no hay datos de ningún contaminante
    if (pollutants.isEmpty) {
      return const DominantPollutant(
        name: 'N/D',
        value: 0,
        unit: '',
        category: AirQualityCategory.maintenance,
        hasMissingData: true,
      );
    }

    // Ordenar por categoría (peor primero)
    pollutants.sort((a, b) => b.category.index.compareTo(a.category.index));
    final worst = pollutants.first;

    // Si todos están en verde pero hay datos faltantes -> maintenance
    final allGood = pollutants.every((p) => p.category == AirQualityCategory.good);
    if (allGood && hasMissing) {
      return DominantPollutant(
        name: worst.name,
        value: worst.value,
        unit: worst.unit,
        category: AirQualityCategory.maintenance,
        hasMissingData: true,
      );
    }

    return DominantPollutant(
      name: worst.name,
      value: worst.value,
      unit: worst.unit,
      category: worst.category,
      hasMissingData: hasMissing,
    );
  }

  /// Obtiene el color para una categoría
  static Color getColorForCategory(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.good:
        return const Color(0xFF00E400); // Verde
      case AirQualityCategory.acceptable:
        return const Color.fromARGB(255, 255, 204, 0); // Amarillo
      case AirQualityCategory.bad:
        return const Color(0xFFFF7E00); // Naranja
      case AirQualityCategory.veryBad:
        return const Color(0xFFFF0000); // Rojo
      case AirQualityCategory.extremelyBad:
        return const Color(0xFF8F3F97); // Morado
      case AirQualityCategory.maintenance:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  /// Obtiene el color de fondo (más claro) para una categoría
  static Color getBackgroundColorForCategory(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.good:
        return const Color(0xFFE8F5E9); // Verde claro
      case AirQualityCategory.acceptable:
        return const Color(0xFFFCF5D4); // Amarillo claro
      case AirQualityCategory.bad:
        return const Color(0xFFFFF3E0); // Naranja claro
      case AirQualityCategory.veryBad:
        return const Color(0xFFFFEBEE); // Rojo claro
      case AirQualityCategory.extremelyBad:
        return const Color(0xFFF3E5F5); // Morado claro
      case AirQualityCategory.maintenance:
        return const Color(0xFFF5F5F5); // Gris claro
    }
  }

  /// Obtiene el texto de estado para una categoría
  static String getStatusForCategory(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.good:
        return 'Buena';
      case AirQualityCategory.acceptable:
        return 'Aceptable';
      case AirQualityCategory.bad:
        return 'Mala';
      case AirQualityCategory.veryBad:
        return 'Muy Mala';
      case AirQualityCategory.extremelyBad:
        return 'Extremadamente Mala';
      case AirQualityCategory.maintenance:
        return 'Uno o más parámetros fuera de servicio';
    }
  }
}

class _PollutantData {
  final String name;
  final double value;
  final String unit;
  final AirQualityCategory category;

  const _PollutantData(this.name, this.value, this.unit, this.category);
}
