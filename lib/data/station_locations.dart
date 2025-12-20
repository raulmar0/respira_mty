import 'package:latlong2/latlong.dart';

class StationLocation {
  final String name;
  final String id;
  final String apiCode;
  final LatLng coords;

  const StationLocation({
    required this.name,
    required this.id,
    required this.apiCode,
    required this.coords,
  });
}

const stationLocations = <StationLocation>[
  StationLocation(
    name: 'Guadalupe, La Pastora',
    id: 'sureste',
    apiCode: 'SURESTE',
    coords: LatLng(25.664833, -100.243228),
  ),
  StationLocation(
    name: 'San Nicolás, Unidad Laboral',
    id: 'noreste',
    apiCode: 'NORESTE',
    coords: LatLng(25.744907, -100.253085),
  ),
  StationLocation(
    name: 'Monterrey, Obispado',
    id: 'centro',
    apiCode: 'CENTRO',
    coords: LatLng(25.676008, -100.338482),
  ),
  StationLocation(
    name: 'Monterrey, San Bernabé',
    id: 'noroeste',
    apiCode: 'NOROESTE',
    coords: LatLng(25.763074, -100.369531),
  ),
  StationLocation(
    name: 'Santa Catarina, Centro',
    id: 'suroeste',
    apiCode: 'SUROESTE',
    coords: LatLng(25.679495, -100.467793),
  ),
  StationLocation(
    name: 'Escobedo, Santa Luz',
    id: 'norte',
    apiCode: 'NORTE',
    coords: LatLng(25.798761, -100.32721),
  ),
  StationLocation(
    name: 'Apodaca, Centro',
    id: 'noreste2',
    apiCode: 'NORESTE2',
    coords: LatLng(25.777443, -100.188074),
  ),
  StationLocation(
    name: 'García, Sierra Leal',
    id: 'noroeste2',
    apiCode: 'GARCIA',
    coords: LatLng(25.800408, -100.58514),
  ),
  StationLocation(
    name: 'Juarez, Centro',
    id: 'sureste2',
    apiCode: 'SURESTE2',
    coords: LatLng(25.645944, -100.095614),
  ),
  StationLocation(
    name: 'San Pedro, Los Sauces',
    id: 'suroeste2',
    apiCode: '[SAN Pedro]',
    coords: LatLng(25.665135, -100.412788),
  ),
  StationLocation(
    name: 'Cadereyta, Jerónimo Treviño',
    id: 'sureste3',
    apiCode: 'SURESTE3',
    coords: LatLng(25.600796, -99.995262),
  ),
  StationLocation(
    name: 'Monterrey, Pueblo Serena',
    id: 'sur',
    apiCode: 'SUR',
    coords: LatLng(25.616799, -100.273323),
  ),
  StationLocation(
    name: 'San Nicolás, CEDEEM',
    id: 'norte2',
    apiCode: 'NORTE2',
    coords: LatLng(25.730182, -100.310582),
  ),
  StationLocation(
    name: 'Pesquería',
    id: 'este',
    apiCode: 'PESQUERIA',
    coords: LatLng(25.791176, -100.078796),
  ),
  StationLocation(
    name: 'García, Arco Vial',
    id: 'noroeste3',
    apiCode: 'NOROESTE3',
    coords: LatLng(25.784723, -100.46352),
  ),
];
