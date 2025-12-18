import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station.dart';
import '../services/air_quality_service.dart';

final airQualityProvider = FutureProvider<List<Station>>((ref) {
  final service = AirQualityService();
  return service.fetchStations();
});
