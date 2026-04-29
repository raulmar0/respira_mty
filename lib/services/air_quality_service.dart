import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../data/station_locations.dart';
import 'package:flutter/foundation.dart';

/// Wraps the SIMA Nuevo León air quality endpoints.
///
/// Hardened over the original implementation with:
/// - HTTPS for all three endpoints (the `api_indice.php` call used to be
///   plain HTTP).
/// - Per-request timeouts (default 15s) so a hung server doesn't lock up the
///   provider.
/// - One automatic retry with a short backoff on transient failures (network
///   errors, 5xx, timeouts).
/// - Quieter debug output: we keep brief error/info traces but drop the per
///   station JSON dumps that flooded the console on every refresh.
class AirQualityService {
  AirQualityService({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _client;
  final Duration _timeout;

  static const String _baseUrl = 'https://aire.nl.gob.mx/SIMA2017reportes';

  Future<List<Station>> fetchStations() async {
    final stations = <Station>[];

    for (final location in stationLocations) {
      try {
        // 1. Per-station daily report. The body isn't used downstream — this
        //    call acts as a "is the station reporting today?" probe; if it
        //    fails we skip the station entirely.
        final reportUrl =
            '$_baseUrl/ReporteDiariosimaIcars.php?estacion1=${location.apiCode}';
        final reportResponse = await _getWithRetry(reportUrl);
        if (reportResponse == null) continue;

        // 2. Concentration alert parameters (shared across stations).
        final concResponse = await _getWithRetry('$_baseUrl/api_conc.php');
        if (concResponse == null) continue;
        final parametrosAlerta =
            jsonDecode(utf8.decode(concResponse.bodyBytes)) as List<dynamic>;

        // 3. UI index parameters (the actual pollutant readings).
        final paramResponse = await _getWithRetry('$_baseUrl/api_indice.php');
        if (paramResponse == null) continue;
        final parametrosUI =
            jsonDecode(utf8.decode(paramResponse.bodyBytes)) as List<dynamic>;

        // Parse pollutants from parametrosUI
        double? pm10, pm25, o3, no2, so2, co;
        for (final param in parametrosUI) {
          final parameter = param['Parameter'] as String;
          final hrAveData = param['HrAveData'];
          final value = hrAveData is num
              ? hrAveData.toDouble()
              : (hrAveData == "ND"
                  ? null
                  : double.tryParse(hrAveData.toString()));

          switch (parameter) {
            case 'PM10_12':
              pm10 = value;
              break;
            case 'PM25_12':
              pm25 = value;
              break;
            case 'O3m':
              o3 = value;
              break;
            case 'NO2m':
              no2 = value;
              break;
            case 'SO2_1':
              so2 = value;
              break;
            case 'CO8m':
              co = value;
              break;
          }
        }

        final station = Station(
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
          updatedAt: DateTime.now(),
          parametrosAlerta: parametrosAlerta.cast<Map<String, dynamic>>(),
          parametrosUI: parametrosUI.cast<Map<String, dynamic>>(),
        );

        stations.add(station);
      } catch (e) {
        debugPrint('Error fetching data for ${location.apiCode}: $e');
      }
    }

    return stations;
  }

  /// Performs an HTTP GET with [retries] additional attempts on failure.
  /// Returns `null` if every attempt fails (connection error, timeout, or
  /// non-2xx response). Successful responses are returned as-is.
  Future<http.Response?> _getWithRetry(
    String url, {
    int retries = 1,
    Duration backoff = const Duration(milliseconds: 400),
  }) async {
    final uri = Uri.parse(url);
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.get(uri).timeout(_timeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        debugPrint(
          'GET $url -> ${response.statusCode} (attempt ${attempt + 1}/${retries + 1})',
        );
      } catch (e) {
        debugPrint('GET $url failed: $e (attempt ${attempt + 1}/${retries + 1})');
      }
      if (attempt < retries) {
        await Future.delayed(backoff * (attempt + 1));
      }
    }
    return null;
  }
}
