import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/station.dart';
import '../utils/air_quality_scale.dart';
import '../utils/app_colors.dart';

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
                      border: Border.all(color: Colors.black.withOpacity(0.03)),
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
                          if (position.center != null) _center = position.center as LatLng;
                          if (position.zoom != null) _zoom = position.zoom as double;
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
                    final maintenanceBgDark = AppColors.statusFueraServicioCircle.withOpacity(0.12);
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
                                            color: theme.shadowColor.withOpacity(0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  "Contaminantes",
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
                                            color: theme.shadowColor.withOpacity(0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  "Clima",
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

                        // Mapeo de nombre completo
                        final fullNames = {
                          'PM25': 'Partículas PM2.5',
                          'PM2.5': 'Partículas PM2.5',
                          'PM10': 'Partículas PM10',
                          'O3': 'Ozono',
                          'NO2': 'Dióxido de Nitrógeno',
                          'SO2': 'Dióxido de Azufre',
                          'CO': 'Monóxido de Carbono',
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
                            PollutantCardLight(
                              name: displayName,
                              symbol: param,
                              value: valueStr,
                              unit: unit,
                              indicatorColor: color,
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    )
                  else
                    // Contenido simple de Clima (placeholder si no hay datos reales)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No hay datos de clima disponibles',
                                style: TextStyle(fontWeight: FontWeight.w700, color: primaryTextColor),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Intenta volver más tarde o verifica los permisos de ubicación.',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

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
                    color: theme.shadowColor.withOpacity(0.08),
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
            color: theme.shadowColor.withOpacity(0.03),
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
            color: theme.shadowColor.withOpacity(0.1),
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
