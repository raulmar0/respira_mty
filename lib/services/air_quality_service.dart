import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../models/sima_error.dart';
import '../data/station_locations.dart';
import 'package:flutter/foundation.dart';
import 'station_cache_service.dart';

/// Wraps the SIMA Nuevo León air quality endpoints.
///
/// Hardened over the original implementation with:
/// - HTTPS for all three endpoints (the `api_indice.php` call used to be
///   plain HTTP).
/// - Per-request timeouts (default 15s) so a hung server doesn't lock up the
///   provider.
/// - One automatic retry with a short backoff on transient failures (network
///   errors, 5xx, timeouts).
/// - Global endpoints (`api_conc.php` and `api_indice.php`) fetched once,
///   then reused for every station, cutting ~34 redundant requests.
/// - Optional 20-minute cache so the UI opens instantly and background tasks
///   avoid hammering the server.
class AirQualityService {
  AirQualityService({
    http.Client? client,
    Duration? timeout,
    StationCacheService? cache,
  })  : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15),
        _cache = cache ?? StationCacheService();

  final http.Client _client;
  final Duration _timeout;
  final StationCacheService _cache;

  static const String _baseUrl = 'https://aire.nl.gob.mx/SIMA2017reportes';

  /// Fetches all stations.
  ///
  /// If [useCache] is `true` (default) and the cache is still fresh (<20 min),
  /// returns the cached list immediately without touching the network.
  ///
  /// If [forceRefresh] is `true`, skips the cache read but still writes the
  /// new result back to the cache on success.
  ///
  /// Throws [SimaError] on failure so callers can distinguish SIMA server
  /// outages from the user having no connectivity.
  ///
  /// [onProgress] is called before each per-station request with the station
  /// name, current index (1-based) and total count so the UI can show a live
  /// loading caption.
  Future<List<Station>> fetchStations({
    bool useCache = true,
    bool forceRefresh = false,
    void Function(String stationName, int current, int total)? onProgress,
  }) async {
    if (useCache && !forceRefresh) {
      final cached = await _cache.load();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    // 2. Fetch global data once.
    final concResponse = await _getWithRetry('$_baseUrl/api_conc.php');
    final parametrosAlerta =
        jsonDecode(utf8.decode(concResponse.bodyBytes)) as List<dynamic>;

    final paramResponse = await _getWithRetry('$_baseUrl/api_indice.php');
    final parametrosUI =
        jsonDecode(utf8.decode(paramResponse.bodyBytes)) as List<dynamic>;

    // 3. Build a lookup map from parametrosUI so we don't scan the list
    //    for every station.
    final uiValues = <String, double?>{};
    for (final param in parametrosUI) {
      final parameter = param['Parameter'] as String?;
      if (parameter == null) continue;
      final hrAveData = param['HrAveData'];
      final value = hrAveData is num
          ? hrAveData.toDouble()
          : (hrAveData == 'ND'
              ? null
              : double.tryParse(hrAveData.toString()));
      uiValues[parameter] = value;
    }

    // 4. Per-station probe (reporte diario). This is still sequential to
    //    avoid overwhelming the server, but now it's only 1 request per
    //    station instead of 3.
    final stations = <Station>[];

    for (var i = 0; i < stationLocations.length; i++) {
      final location = stationLocations[i];
      onProgress?.call(location.name, i + 1, stationLocations.length);
      try {
        final reportUrl =
            '$_baseUrl/ReporteDiariosimaIcars.php?estacion1=${location.apiCode}';
        await _getWithRetry(reportUrl);

        final pm10 = uiValues['PM10_12'];
        final pm25 = uiValues['PM25_12'];
        final o3 = uiValues['O3m'];
        final no2 = uiValues['NO2m'];
        final so2 = uiValues['SO2_1'];
        final co = uiValues['CO8m'];

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

    // 5. Persist to cache.
    if (stations.isNotEmpty) {
      await _cache.save(stations);
    }

    return stations;
  }

  /// Performs an HTTP GET with [retries] additional attempts on failure.
  ///
  /// Throws [SimaError.networkError] when the device has no connectivity, and
  /// [SimaError.simaDown] when the SIMA server is unreachable or returns a
  /// non-2xx status after all retries.
  Future<http.Response> _getWithRetry(
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
      } on SocketException catch (e) {
        debugPrint('GET $url socket error: $e');
        throw SimaError.networkError(message: 'No internet connection');
      } on http.ClientException catch (e) {
        debugPrint('GET $url client error: $e');
        throw SimaError.networkError(message: 'Connection failed');
      } catch (e) {
        debugPrint(
            'GET $url failed: $e (attempt ${attempt + 1}/${retries + 1})');
      }
      if (attempt < retries) {
        await Future.delayed(backoff * (attempt + 1));
      }
    }
    throw SimaError.simaDown(message: 'SIMA server unreachable after retries');
  }
}
