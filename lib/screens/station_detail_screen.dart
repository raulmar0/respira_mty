import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/station.dart';
import '../utils/air_quality_scale.dart';
import '../utils/app_colors.dart';
import 'pollutant_detail_screen.dart';
import 'package:respira_mty/l10n/app_localizations.dart';

class StationDetailScreenLight extends StatefulWidget {
  final Station station;
  const StationDetailScreenLight({super.key, required this.station});

  @override
  State<StationDetailScreenLight> createState() =>
      _StationDetailScreenLightState();
}

class _StationDetailScreenLightState extends State<StationDetailScreenLight> {
  bool showPollutants = true;
  final MapController _mapController = MapController();
  late LatLng _center;
  double _zoom = 13.0;

  // Expose zoom for tests
  double get currentZoom => _zoom;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.station.latitude, widget.station.longitude);
    _zoom = 13.0;
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station; // shorthand
    final municipality = station.name.split(',').first.trim();
    final dominant = station.dominantPollutant;
    final statusTextColor = dominant.statusTextColor;
    final statusBg = dominant.statusBackground;
    final statusCircle = dominant.statusColors.circle;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors from theme
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.textTheme.headlineSmall?.color ?? (isDark ? Colors.white : Colors.black87);
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? (isDark ? Colors.grey[400] : Colors.grey[600]);
    final iconColor = theme.iconTheme.color ?? (isDark ? Colors.white : const Color(0xFF111827));

    return Scaffold(
      backgroundColor: backgroundColor,

      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // --- CABECERA ---
                  Text(
                    municipality,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800, // Extra bold
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pill de Estado (color dinámico según status)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusCircle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          station.status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN LOCATION ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mapa (centrado en coordenadas de la estación) con controles de zoom
                  Container(
                    height: 220,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                    ),
                    child: Stack(
                      children: [
                AbsorbPointer(
                  absorbing: true,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        station.latitude,
                        station.longitude,
                      ),
                      initialZoom: _zoom,
                      onPositionChanged: (position, _) {
                        setState(() {
                          _center = position.center;
                          _zoom = position.zoom;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.respira_mty',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              station.latitude,
                              station.longitude,
                            ),
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.aqiGreen,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                        // Controles de Zoom
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final newZoom = (_zoom + 1.0).clamp(
                                    1.0,
                                    20.0,
                                  );
                                  _mapController.move(_center, newZoom);
                                  setState(() => _zoom = newZoom);
                                },
                                child: _ZoomButton(
                                  key: const Key('zoom_in'),
                                  icon: Icons.add,
                                  backgroundColor: cardColor,
                                  iconColor: iconColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  final newZoom = (_zoom - 1.0).clamp(
                                    1.0,
                                    20.0,
                                  );
                                  _mapController.move(_center, newZoom);
                                  setState(() => _zoom = newZoom);
                                },
                                child: _ZoomButton(
                                  key: const Key('zoom_out'),
                                  icon: Icons.remove,
                                  backgroundColor: cardColor,
                                  iconColor: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- TOGGLE SWITCH (Contaminantes / Clima) ---
                  // Usamos colores de 'mantenimiento' para mejor contraste y adaptabilidad a modo oscuro
                  Builder(builder: (ctx) {
                    final maintenanceBgLight = AppColors.statusFueraServicioBackground;
                    final maintenanceTextLight = AppColors.statusFueraServicioText;
                    final maintenanceBgDark = AppColors.statusFueraServicioCircle.withValues(alpha: 0.12);
                    final switchBg = isDark ? maintenanceBgDark : maintenanceBgLight;

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: switchBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => showPollutants = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: showPollutants
                                      ? (isDark ? AppColors.statusFueraServicioCircle : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: showPollutants
                                      ? [
                                          BoxShadow(
                                            color: theme.shadowColor.withValues(alpha: 0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.tabPollutants,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: showPollutants ? (isDark ? Colors.white : maintenanceTextLight) : secondaryTextColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => showPollutants = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !showPollutants
                                      ? (isDark ? AppColors.statusFueraServicioCircle : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: !showPollutants
                                      ? [
                                          BoxShadow(
                                            color: theme.shadowColor.withValues(alpha: 0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.tabWeather,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !showPollutants ? (isDark ? Colors.white : maintenanceTextLight) : secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // --- CONTENIDO: Contaminantes o Clima ---
                  if (showPollutants)
                    Column(
                      children: station.pollutantsFromUI.map((p) {
                        final param = p['parameter'] as String? ?? '';
                        final val = p['value'];
                        final valueStr = val == null
                            ? 'N/D'
                            : (param.toUpperCase().contains('CO')
                                  ? (val as double).toStringAsFixed(1)
                                  : (val as double).toStringAsFixed(0));
                        final unit = p['unit'] as String? ?? '';

                        // Mapeo de nombre completo usando localizaciones
                        final fullNames = {
                          'PM25': AppLocalizations.of(context)!.pm2_5,
                          'PM2.5': AppLocalizations.of(context)!.pm2_5,
                          'PM10': AppLocalizations.of(context)!.pm10,
                          'O3': AppLocalizations.of(context)!.o3,
                          'NO2': AppLocalizations.of(context)!.no2,
                          'SO2': AppLocalizations.of(context)!.so2,
                          'CO': AppLocalizations.of(context)!.co,
                        };

                        final displayName =
                            fullNames[param.toUpperCase()] ??
                            (p['label'] as String? ?? param);

                        final color = (val != null)
                            ? AirQualityScale.getColorForParameter(
                                param,
                                val as double,
                              )
                            : Colors.grey;

                        return Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (c) => PollutantDetailScreen(
                                      parameter: param,
                                      value: val as double?,
                                      unit: unit,
                                      color: color,
                                    ),
                                  ),
                                );
                              },
                              child: PollutantCardLight(
                                name: displayName,
                                symbol: param,
                                value: valueStr,
                                unit: unit,
                                indicatorColor: color,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    )
                  else
                    // Sección de Clima embebida
                    const _WeatherSection(),

                  // Espacio extra al final
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: iconColor,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- WIDGETS AUXILIARES ----------------

// 1. Tarjeta de Contaminante (Estilo Blanco / Light)
class PollutantCardLight extends StatelessWidget {
  final String name;
  final String symbol;
  final String value;
  final String unit;
  final Color? indicatorColor;

  const PollutantCardLight({
    super.key,
    required this.name,
    required this.symbol,
    required this.value,
    required this.unit,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localCardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final localPrimaryTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final localSecondaryTextColor = theme.textTheme.bodySmall?.color ?? (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: localCardColor,
        borderRadius: BorderRadius.circular(16),
        // Sombra sutil
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (indicatorColor != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: localPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    symbol.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: localSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: localPrimaryTextColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: localSecondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- SECCIÓN: Clima (embebida en Station Detail) ---
class _WeatherSection extends StatelessWidget {
  const _WeatherSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tarjeta Principal
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.blue.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temperatura Actual', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('28°', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white)),
                  Icon(Icons.wb_cloudy, size: 52, color: Colors.white),
                ],
              ),
              const SizedBox(height: 6),
                Text(AppLocalizations.of(context)!.partlyCloudy, style: TextStyle(color: Colors.white70, fontSize: 14)),

              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.25)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WeatherMainDetail(label: 'Humedad', value: '45%'),
                  _WeatherMainDetail(label: 'Viento', value: '12 km/h'),
                  _WeatherMainDetail(label: 'Presión', value: '1012 mb'),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2. Tarjetas pequeñas (Viento / Precipitación)
        Row(
          children: [
            Expanded(
              child: _WeatherSmallCard(
                title: 'VIENTO',
                value: 'NE',
                subValue: 'Dirección',
                icon: Icons.air,
                isWind: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherSmallCard(
                title: 'PRECIPITACIÓN',
                value: '0%',
                subValue: 'Probabilidad',
                icon: Icons.water_drop,
                isWind: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 3. Pronóstico por hora
        Text(AppLocalizations.of(context)!.forecastTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor)),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _WeatherHourlyItem(time: 'AHORA', icon: Icons.wb_cloudy, temp: '28°'),
              _WeatherHourlyItem(time: '14:00', icon: Icons.wb_sunny, temp: '30°'),
              _WeatherHourlyItem(time: '16:00', icon: Icons.wb_sunny, temp: '29°'),
              _WeatherHourlyItem(time: '18:00', icon: Icons.cloud, temp: '26°'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. Pronóstico diario
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: const [
              _WeatherDailyItem(day: 'Mar', icon: Icons.wb_sunny, label: 'Soleado', max: '32°', min: '18°', iconColor: Colors.orange),
              Divider(),
              _WeatherDailyItem(day: 'Mié', icon: Icons.cloud, label: 'Nublado', max: '29°', min: '19°', iconColor: Colors.grey),
              Divider(),
              _WeatherDailyItem(day: 'Jue', icon: Icons.beach_access, label: 'Lluvia', max: '24°', min: '17°', iconColor: Colors.blue),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

// Sub-widgets para la sección de clima
class _WeatherMainDetail extends StatelessWidget {
  final String label;
  final String value;
  const _WeatherMainDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _WeatherSmallCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;
  final IconData icon;
  final bool isWind;

  const _WeatherSmallCard({required this.title, required this.value, required this.subValue, required this.icon, required this.isWind});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(subValue, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              if (isWind)
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle), child: const Icon(Icons.navigation, color: Colors.green, size: 18)),
            ],
          )
        ],
      ),
    );
  }
}

class _WeatherHourlyItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const _WeatherHourlyItem({required this.time, required this.icon, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Icon(icon, size: 26, color: const Color(0xFF102A43)), const SizedBox(height: 8), Text(temp, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }
}

class _WeatherDailyItem extends StatelessWidget {
  final String day;
  final IconData icon;
  final String label;
  final String max;
  final String min;
  final Color iconColor;
  const _WeatherDailyItem({required this.day, required this.icon, required this.label, required this.max, required this.min, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [SizedBox(width: 40, child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), Icon(icon, color: iconColor), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Text(max, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12), Text(min, style: const TextStyle(color: Colors.grey))]),
    );
  }
}

// 2. Botón de Zoom (Redondo blanco)
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  const _ZoomButton({super.key, required this.icon, this.backgroundColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor ?? (theme.cardTheme.color ?? theme.colorScheme.surface),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor ?? theme.iconTheme.color ?? const Color(0xFF4B5563), size: 20),
    );
  }
}

// 3. Indicador Pulsante Verde
class PulsingIndicator extends StatefulWidget {
  const PulsingIndicator({super.key});
  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.aqiGreen; // Verde brillante (theme neutral)
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo externo que se desvanece
          FadeTransition(
            opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 2.5).animate(_controller),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                ),
              ),
            ),
          ),
          // Punto central sólido
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary,
              // Borde blanco fino para destacar del fondo si es necesario
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. CustomPainter para el patrón de puntos del mapa
class DotPatternPainter extends CustomPainter {
  final Color color;
  DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double spacing = 25.0; // Espacio entre puntos
    const double radius = 1.5; // Tamaño del punto

    for (double x = 10; x < size.width; x += spacing) {
      for (double y = 10; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
