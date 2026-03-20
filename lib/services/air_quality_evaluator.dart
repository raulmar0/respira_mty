import '../models/station.dart';
import '../utils/air_quality_scale.dart';

class AirQualityAlert {
  final Station station;
  final DominantPollutant dominantPollutant;

  const AirQualityAlert({
    required this.station,
    required this.dominantPollutant,
  });
}

const _unhealthyCategories = {
  AirQualityCategory.bad,
  AirQualityCategory.veryBad,
  AirQualityCategory.extremelyBad,
};

/// Evaluates all stations and returns alerts for those with unhealthy air quality.
/// Pure function — no Flutter dependency, easily testable.
List<AirQualityAlert> evaluateStations(List<Station> stations) {
  return stations
      .where((s) => _unhealthyCategories.contains(s.dominantPollutant.category))
      .map((s) => AirQualityAlert(
            station: s,
            dominantPollutant: s.dominantPollutant,
          ))
      .toList();
}
