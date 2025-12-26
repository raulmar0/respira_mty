import 'package:flutter/material.dart';
import '../utils/air_quality_scale.dart';
import '../data/pollutants.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/l10n/app_localizations_ext.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class PollutantDetailScreen extends StatefulWidget {
  final String parameter;
  final double? value;
  final String unit;
  final Color? color; // color to use for indicator and accent

  const PollutantDetailScreen({
    super.key,
    required this.parameter,
    this.value,
    this.unit = '',
    this.color,
  });

  @override
  State<PollutantDetailScreen> createState() => _PollutantDetailScreenState();
}

class _PollutantDetailScreenState extends State<PollutantDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // Mapa simple de descripciones por contaminante (en español)
  String _getDescription(BuildContext context, String param) {
    final loc = AppLocalizations.of(context)!;
    switch (param.toUpperCase()) {
      case 'PM2.5':
      case 'PM25':
      case 'PM25M':
      case 'PM2.5M':
        return loc.pm25_desc;
      case 'PM10':
      case 'PM10M':
        return loc.pm10_desc;
      case 'O3':
      case 'O3M':
        return loc.o3_desc;
      case 'NO2':
      case 'NO2M':
        return loc.no2_desc;
      case 'SO2':
      case 'SO2M':
        return loc.so2_desc;
      case 'CO':
      case 'COM':
        return loc.co_desc;
      default:
        return loc.genericPollutantInfo;
    }
  }

  Future<void> _shareScreen() async {
    // Capture the full content using the controller attached to the widget in the tree
    final capturedImage = await _screenshotController.capture();

    if (capturedImage == null) return;

    // Save to temp file
    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/pollutant_share.png').create();
    await imagePath.writeAsBytes(capturedImage);

    // Share
    if (mounted) {
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Detalle de ${widget.parameter}',
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    final displayLabel = _getDisplayLabel(widget.parameter);
    final displayValue = widget.value != null
        ? (widget.parameter.toUpperCase().contains('CO') ? widget.value!.toStringAsFixed(1) : widget.value!.toStringAsFixed(0))
        : 'N/D';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final indicatorColor = widget.color ?? AirQualityScale.getColorForParameter(widget.parameter, widget.value ?? 0);

    // Theme-aware colors for light/dark
    final cardColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF0F1724) : Colors.white);
    final primaryTextColor = theme.textTheme.headlineMedium?.color ?? (isDark ? Colors.white : const Color(0xFF1A202C));
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? (isDark ? Colors.grey[400] : Colors.grey[600]);
    final badgeBg = isDark ? Colors.grey[900] : Colors.grey[100];

    return Screenshot(
      controller: _screenshotController,
      child: Container(
        color: theme.scaffoldBackgroundColor, // Ensure background is captured
        child: Column(
          children: [
            // Main card: value, unit, abbreviation, description and quality badge
            Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: isDark ? 0.6 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Numeric value
                      Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Unit
                      Text(
                        widget.unit.isNotEmpty ? widget.unit : AirQualityScale.getUnitForParameter(widget.parameter),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Abbreviation (e.g., PM2.5)
                      Text(
                        displayLabel,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primaryTextColor),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _getDescription(context, widget.parameter),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: secondaryTextColor, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Badge / Chip of quality
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: indicatorColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getQualityLabel(widget.parameter, widget.value, context),
                              style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    
                const SizedBox(height: 20),
                // Keep displayLabel & description duplicate removed since included in card
              ],
            ),
    
            const SizedBox(height: 30),
    
            // Contenido dinámico: método de medición, riesgos y fuentes según el contaminante
            const SizedBox(height: 10),
            Builder(builder: (context) {
              final key = _normalizeParameter(widget.parameter);
              final info = pollutantMap[key];
              if (info == null) {
                // Fallback: mostrar la información genérica si no existe dato específico
                return Column(
                  children: [
                    _buildSectionHeader(Icons.medical_services_outlined, AppLocalizations.of(context)!.risksTitle, Colors.green),
                    const SizedBox(height: 10),
                    // Localized fallback risk entries for pollutants without specific info
                    _buildInfoCard(
                      context,
                      icon: Icons.air,
                      iconColor: Colors.redAccent,
                      bgColor: const Color(0xFFFFEBEE),
                      title: AppLocalizations.of(context)!.respiratoryProblems,
                      description: AppLocalizations.of(context)!.respiratoryProblemsDesc,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader(Icons.factory_outlined, AppLocalizations.of(context)!.sourcesTitle, Colors.green),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      context,
                      icon: Icons.directions_car,
                      iconColor: Colors.blueGrey,
                      bgColor: const Color(0xFFECEFF1),
                      title: AppLocalizations.of(context)!.vehicleEmissions,
                      description: AppLocalizations.of(context)!.vehicleEmissionsDesc,
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              }
    
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
    
    
                  // Riesgos
                  _buildSectionHeader(Icons.medical_services_outlined, AppLocalizations.of(context)!.risksTitle, Colors.green),
                  const SizedBox(height: 10),
                  if (info.risks.shortTerm.isNotEmpty) ...[
                    Text(AppLocalizations.of(context)!.shortTerm, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: info.risks.shortTerm.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildRiskCard(context, r),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (info.risks.longTerm.isNotEmpty) ...[
                    Text(AppLocalizations.of(context)!.longTerm, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: info.risks.longTerm.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildRiskCard(context, r),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
    
                  const SizedBox(height: 8),
                  // Fuentes
                  _buildSectionHeader(Icons.factory_outlined, AppLocalizations.of(context)!.sourcesTitle, Colors.green),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: info.sources.map((s) {
                      final label = AppLocalizations.of(context)!.translateKey(s.textKey);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(s.icon, color: Colors.blueGrey, size: 18),
                            const SizedBox(width: 8),
                            Text(label, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
    
                  // Método de medición (moved to the end; simplified)
                  const SizedBox(height: 12),
                  _buildSectionHeader(Icons.science, AppLocalizations.of(context)!.measurementMethod, Colors.green),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: isDark ? 0.6 : 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(info.method.icon, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text(AppLocalizations.of(context)!.translateKey(info.method.methodKey), style: TextStyle(fontSize: 13, color: secondaryTextColor))),
                      ],
                    ),
                  ),
    
                  const SizedBox(height: 40),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF0F1724) : Colors.white);
    final primaryTextColor = theme.textTheme.headlineMedium?.color ?? (isDark ? Colors.white : const Color(0xFF1A202C));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardColor,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.pollutantDetailTitle,
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
            ),
            child: IconButton(
              icon: Icon(Icons.share_outlined, color: primaryTextColor),
              onPressed: _shareScreen,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.4),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColorLocal = theme.cardTheme.color ?? (isDark ? const Color(0xFF0F1724) : Colors.white);
    final textColor = theme.textTheme.bodySmall?.color ?? (isDark ? Colors.grey[300] : Colors.black87);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColorLocal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.6 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayLabel(String parameter) {
    switch (parameter.toUpperCase()) {
      case 'PM10M':
        return 'PM10';
      case 'PM25M':
        return 'PM2.5';
      case 'O3M':
        return 'O3';
      case 'NO2M':
        return 'NO2';
      case 'SO2M':
        return 'SO2';
      case 'COM':
        return 'CO';
      default:
        return parameter;
    }
  }

  String _getQualityLabel(String parameter, double? value, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (value == null) return loc.dataUnavailable;
    final color = AirQualityScale.getColorForParameter(parameter, value);
    // Map color to text label using categories (a simplification)
    // Reusing AirQualityScale thresholds indirectly by comparing colors
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.good)) return loc.airQualityGood;
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.acceptable)) return loc.airQualityAcceptable;
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.bad)) return loc.airQualityBad;
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.veryBad)) return loc.airQualityVeryBad;
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.extremelyBad)) return loc.airQualityExtremelyBad;
    return loc.airQualityUnknown;
  }

  // Normaliza parámetros a claves del mapa de datos
  String _normalizeParameter(String param) {
    final p = param.toUpperCase();
    switch (p) {
      case 'PM10M':
      case 'PM10_12':
      case 'PM10':
        return 'PM10';
      case 'PM25M':
      case 'PM2.5':
      case 'PM25_12':
      case 'PM25':
        return 'PM25';
      case 'O3':
      case 'O3M':
        return 'O3';
      case 'NO2':
      case 'NO2M':
        return 'NO2';
      case 'SO2':
      case 'SO2M':
        return 'SO2';
      case 'CO':
      case 'COM':
      case 'CO8M':
        return 'CO';
      default:
        return p;
    }
  }


  Widget _buildRiskCard(BuildContext context, NamedIcon namedIcon) {
    final icon = namedIcon.icon;
    final theme = Theme.of(context);
    final isDarkRow = theme.brightness == Brightness.dark;
    final bg = theme.cardTheme.color ?? (isDarkRow ? const Color(0xFF0F1724) : Colors.white);
    final shadowColor = theme.shadowColor.withValues(alpha: isDarkRow ? 0.6 : 0.02);
    final textColor = theme.textTheme.bodySmall?.color ?? (isDarkRow ? Colors.grey[300] : Colors.black87);

    final label = AppLocalizations.of(context)!.translateKey(namedIcon.textKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 18, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: textColor))),
        ],
      ),
    );
  }
}

