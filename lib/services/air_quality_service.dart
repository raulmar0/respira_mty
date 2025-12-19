import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/station_locations.dart';
import '../models/station.dart';

class AirQualityService {
  static const String _baseUrl = 'http://aire.nl.gob.mx/SIMA2017reportes';
  final http.Client _client;

  AirQualityService([http.Client? client]) : _client = client ?? http.Client();

  Future<List<Station>> fetchStations() async {
    final stations = <Station>[];

    try {
      for (final location in stationLocations) {
        debugPrint('Requesting air data for ${location.apiCode}');

        await _client.get(
          Uri.parse('$_baseUrl/ReporteDiariosima.php').replace(
            queryParameters: {'estacion1': location.apiCode},
          ),
        );

        final concentrationResponse =
            await _client.get(Uri.parse('$_baseUrl/api_conc.php'));
        final parameterResponse =
            await _client.get(Uri.parse('$_baseUrl/api_parametrosI.php'));

        final concentrations = _decodeList(concentrationResponse.body);
        final parameters = _decodeList(parameterResponse.body);

        final pm25 = _extractValue(concentrations, 'PM2.5');
        final pm10 = _extractValue(concentrations, 'PM10');
        final o3 = _extractValue(concentrations, 'O3');
        final no2 = _extractValue(concentrations, 'NO2');
        final so2 = _extractValue(concentrations, 'SO2');
        final co = _extractValue(concentrations, 'CO');

        final updatedAt = _extractDate(concentrations) ?? _extractDate(parameters);

        stations.add(Station(
          id: location.id,
          apiCode: location.apiCode,
          name: location.name,
          pm25: pm25,
          pm10: pm10,
          o3: o3,
          no2: no2,
          so2: so2,
          co: co,
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          isFavorite: location.id == 'centro',
          updatedAt: updatedAt,
        ));

        await Future.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      _client.close();
    }

    return stations;
  }


  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    }
    return const [];
  }

  double? _extractValue(List<Map<String, dynamic>> values, String target) {
    final normalizedTarget = _normalizeParameter(target);
    for (final entry in values) {
      final raw = entry['Parameter'] as String?;
      if (raw == null) continue;
      if (_normalizeParameter(raw) == normalizedTarget) {
        return _toDouble(entry['HrAveData']);
      }
    }
    return null;
  }

  DateTime? _extractDate(List<Map<String, dynamic>> values) {
    for (final entry in values) {
      final raw = entry['Date'] as String?;
      if (raw == null) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final cleaned = value.toString().replaceAll(',', '.').trim();
    return double.tryParse(cleaned);
  }

  String _normalizeParameter(String value) {
    return value.replaceAll(RegExp(r'[\.\s]'), '').toUpperCase();
  }
}

