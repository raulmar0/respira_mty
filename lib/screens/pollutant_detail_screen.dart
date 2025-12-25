import 'package:flutter/material.dart';
import '../utils/air_quality_scale.dart';

class PollutantDetailScreen extends StatelessWidget {
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

  // Mapa simple de descripciones por contaminante (en español)
  String _getDescription(String param) {
    switch (param.toUpperCase()) {
      case 'PM2.5':
      case 'PM25':
      case 'PM25M':
      case 'PM2.5M':
        return 'Partículas finas inhalables con diámetros de 2.5 micrómetros o menos.';
      case 'PM10':
      case 'PM10M':
        return 'Partículas inhalables con diámetros de 10 micrómetros o menos.';
      case 'O3':
      case 'O3M':
        return 'Ozono troposférico, irritante respiratorio que puede agravar problemas respiratorios.';
      case 'NO2':
      case 'NO2M':
        return 'Dióxido de nitrógeno, puede causar irritación y empeorar enfermedades respiratorias.';
      case 'SO2':
      case 'SO2M':
        return 'Dióxido de azufre, puede irritar las vías respiratorias y agravar el asma.';
      case 'CO':
      case 'COM':
        return 'Monóxido de carbono, reduce la capacidad de la sangre para transportar oxígeno.';
      default:
        return 'Información sobre este contaminante.';
    }
  }

  // Valores máximos aproximados para normalizar el gauge (no científico, solo visual)
  double _maxForParameter(String param) {
    switch (param.toUpperCase()) {
      case 'PM2.5':
      case 'PM25':
      case 'PM25M':
        return 150.0;
      case 'PM10':
      case 'PM10M':
        return 250.0;
      case 'O3':
      case 'O3M':
        return 200.0;
      case 'NO2':
      case 'NO2M':
        return 250.0;
      case 'SO2':
      case 'SO2M':
        return 350.0;
      case 'CO':
      case 'COM':
        return 20.0;
      default:
        return 100.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = _getDisplayLabel(parameter);
    final displayValue = value != null
        ? (parameter.toUpperCase().contains('CO') ? value!.toStringAsFixed(1) : value!.toStringAsFixed(0))
        : 'N/D';

    final indicatorColor = color ?? AirQualityScale.getColorForParameter(parameter, value ?? 0);

    final normalized = (value != null) ? (value! / _maxForParameter(parameter)).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Detalle: $displayLabel',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Gauge
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: normalized,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          displayValue,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          unit.isNotEmpty ? unit : AirQualityScale.getUnitForParameter(parameter),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  displayLabel,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF102A43)),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _getDescription(parameter),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.blueGrey, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: indicatorColor, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        _getQualityLabel(parameter, value),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF102A43)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Riesgos y fuentes: se muestran genéricos pero útiles. Mantengo estructura del diseño original.
            const SizedBox(height: 10),
            _buildSectionHeader(Icons.medical_services_outlined, 'Riesgos', Colors.green),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.air,
              iconColor: Colors.redAccent,
              bgColor: const Color(0xFFFFEBEE),
              title: 'Problemas Respiratorios',
              description: 'La exposición a corto plazo puede irritar los pulmones y causar tos o dificultad para respirar.',
            ),
            _buildInfoCard(
              icon: Icons.favorite,
              iconColor: Colors.orange,
              bgColor: const Color(0xFFFFF3E0),
              title: 'Salud Cardiovascular',
              description: 'Algunos contaminantes pueden afectar la función cardíaca.',
            ),
            _buildInfoCard(
              icon: Icons.people,
              iconColor: Colors.amber,
              bgColor: const Color(0xFFFFF8E1),
              title: 'Grupos Vulnerables',
              description: 'Niños, ancianos y personas con enfermedades preexistentes corren mayor riesgo.',
            ),

            const SizedBox(height: 25),

            _buildSectionHeader(Icons.factory_outlined, 'Fuentes', Colors.green),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.directions_car,
              iconColor: Colors.blueGrey,
              bgColor: const Color(0xFFECEFF1),
              title: 'Emisiones de Vehículos',
              description: 'Automóviles, camiones y autobuses.',
            ),
            _buildInfoCard(
              icon: Icons.factory,
              iconColor: Colors.blueGrey,
              bgColor: const Color(0xFFECEFF1),
              title: 'Industria y Manufactura',
              description: 'Fábricas, plantas de energía y fundiciones.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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

  String _getQualityLabel(String parameter, double? value) {
    if (value == null) return 'Datos no disponibles';
    final color = AirQualityScale.getColorForParameter(parameter, value);
    // Map color to text label using categories (a simplification)
    // Reusing AirQualityScale thresholds indirectly by comparing colors
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.good)) return 'Calidad Buena';
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.acceptable)) return 'Calidad Aceptable';
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.bad)) return 'Calidad Mala';
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.veryBad)) return 'Calidad Muy Mala';
    if (color == AirQualityScale.getColorForCategory(AirQualityCategory.extremelyBad)) return 'Calidad Extremadamente Mala';
    return 'Calidad Desconocida';
  }
}
