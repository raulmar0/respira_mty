import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../data/station_locations.dart';
import 'package:flutter/foundation.dart';

class AirQualityService {
  Future<List<Station>> fetchStations() async {
    final stations = <Station>[];

    for (final location in stationLocations) {
      try {
        // 1. Esperar respuesta de ReporteDiariosima.php
        final reportUrl = 'https://aire.nl.gob.mx/SIMA2017reportes/ReporteDiariosimaIcars.php?estacion1=${location.apiCode}';
        final reportResponse = await http.get(Uri.parse(reportUrl));
        if (reportResponse.statusCode != 200) {
          debugPrint('Error fetching report for ${location.apiCode}: ${reportResponse.statusCode}');
          continue;
        }

        // // Esperar 300ms antes de llamar los demás endpoints
        // await Future.delayed(Duration(milliseconds: 1000));

        // 2. Hacer GET a api_conc.php y guardar en parametrosAlerta
        final concUrl = 'https://aire.nl.gob.mx/SIMA2017reportes/api_conc.php';
        final concResponse = await http.get(Uri.parse(concUrl));
        if (concResponse.statusCode != 200) {
          debugPrint('Error fetching conc for ${location.apiCode}: ${concResponse.statusCode}');
          continue;
        }
        final parametrosAlerta = jsonDecode(utf8.decode(concResponse.bodyBytes)) as List<dynamic>;

        // 3. Hacer GET a api_indice.php y guardar en parametrosUI
        final paramUrl = 'http://aire.nl.gob.mx/SIMA2017reportes/api_indice.php';
        final paramResponse = await http.get(Uri.parse(paramUrl));
        if (paramResponse.statusCode != 200) {
          debugPrint('Error fetching param for ${location.apiCode}: ${paramResponse.statusCode}');
          continue;
        }
        final parametrosUI = jsonDecode(utf8.decode(paramResponse.bodyBytes)) as List<dynamic>; 

        // Parse pollutants from parametrosUI
        double? pm10, pm25, o3, no2, so2, co;
        for (final param in parametrosUI) {
          final parameter = param['Parameter'] as String;
          final hrAveData = param['HrAveData'];
          final value = hrAveData is num ? hrAveData.toDouble() : (hrAveData == "ND" ? null : double.tryParse(hrAveData.toString()));

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

        // Log the station
        debugPrint('------------');
        debugPrint(station.name);
        debugPrint('api_conc.php:');
        debugPrint('{');
        final prettyConc = JsonEncoder.withIndent('  ').convert(parametrosAlerta);
        debugPrint(prettyConc);
        debugPrint('}');
        debugPrint('api_indice.php');
        debugPrint('{');
        final prettyParam = JsonEncoder.withIndent('  ').convert(parametrosUI);
        debugPrint(prettyParam);
        debugPrint('}');
        debugPrint('model');
        debugPrint('----------------------');

      } catch (e) {
        debugPrint('Error fetching data for ${location.apiCode}: $e');
      }


    }

    return stations;
  }
}

