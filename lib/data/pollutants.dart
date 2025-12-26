import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';

class PollutantInfo {
  final String symbol;
  final String name;
  final String description;
  final Measurement method;
  final List<NamedIcon> sources;
  final Risks risks;

  const PollutantInfo({
    required this.symbol,
    required this.name,
    required this.description,
    required this.method,
    required this.sources,
    required this.risks,
  });
}

class Measurement {
  final String method;
  final String iconName;

  const Measurement({required this.method, required this.iconName});

  IconData get icon => iconFromName(iconName);
}

class NamedIcon {
  final String text;
  final String iconName;

  const NamedIcon({required this.text, required this.iconName});

  IconData get icon => iconFromName(iconName);
}

class Risks {
  final List<NamedIcon> shortTerm;
  final List<NamedIcon> longTerm;

  const Risks({required this.shortTerm, required this.longTerm});
}

// Data map keyed by parameter symbol (normalized like PM10, PM25, O3, NO2, SO2, CO)
const Map<String, PollutantInfo> pollutantMap = {
  'PM10': PollutantInfo(
    symbol: 'PM10',
    name: 'Material Particulado menor a 10 micrómetros',
    description:
        'Mezcla compleja de partículas líquidas o sólidas que provienen de fuentes naturales o antropogénicas, poseen un tamaño aerodinámico menor a 10 micrómetros.',
    method: Measurement(method: 'Atenuación de rayos Beta y Dispersión de luz blanca', iconName: 'science'),
    sources: [
      NamedIcon(text: 'Polvo resuspendido en calles', iconName: 'grain'),
      NamedIcon(text: 'Actividades de construcción', iconName: 'construction'),
      NamedIcon(text: 'Industria extractiva (pedreras)', iconName: 'landscape'),
      NamedIcon(text: 'Quema de combustibles', iconName: 'local_gas_station'),
      NamedIcon(text: 'Erosión del suelo', iconName: 'terrain'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(text: 'Aumento de morbimortalidad respiratoria', iconName: 'local_hospital'),
        NamedIcon(text: 'Disminución en la función pulmonar', iconName: 'air'),
        NamedIcon(text: 'Interferencia en mecanismos de defensa pulmonar', iconName: 'shield'),
        NamedIcon(text: 'Síndrome bronquial obstructivo', iconName: 'block'),
      ],
      longTerm: [
        NamedIcon(text: 'Menor desarrollo del sistema respiratorio', iconName: 'child_care'),
        NamedIcon(text: 'Mayor riesgo de cáncer (HAPs)', iconName: 'warning'),
      ],
    ),
  ),

  'PM25': PollutantInfo(
    symbol: 'PM25',
    name: 'Material Particulado menor a 2.5 micrómetros',
    description:
        'Mezcla Compleja de Partículas líquidas o sólidas que provienen principalmente de fuentes antropogénicas, poseen un tamaño aerodinámico menor a 2.5 micrómetros.',
    method: Measurement(method: 'Atenuación de rayos Beta y Dispersión de luz blanca', iconName: 'science'),
    sources: [
      NamedIcon(text: 'Combustión de vehículos (diésel)', iconName: 'directions_bus'),
      NamedIcon(text: 'Procesos industriales', iconName: 'factory'),
      NamedIcon(text: 'Quemas agrícolas', iconName: 'agriculture'),
      NamedIcon(text: 'Incendios forestales', iconName: 'forest'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(text: 'Aumento de morbimortalidad respiratoria', iconName: 'local_hospital'),
        NamedIcon(text: 'Disminución en la función pulmonar', iconName: 'air'),
        NamedIcon(text: 'Interferencia en mecanismos de defensa pulmonar', iconName: 'shield'),
        NamedIcon(text: 'Síndrome bronquial obstructivo', iconName: 'block'),
      ],
      longTerm: [
        NamedIcon(text: 'Menor desarrollo del sistema respiratorio', iconName: 'child_care'),
        NamedIcon(text: 'Mayor riesgo de cáncer (HAPs)', iconName: 'warning'),
      ],
    ),
  ),

  'SO2': PollutantInfo(
    symbol: 'SO2',
    name: 'Dióxido de Azufre',
    description:
        'Gas formado por 2 átomos de oxígeno y uno de azufre, se forma principalmente por la combustión de combustibles fósiles con alto contenido de azufre.',
    method: Measurement(method: 'Fluorescencia pulsante UV', iconName: 'light_mode'),
    sources: [
      NamedIcon(text: 'Refinerías de petróleo', iconName: 'oil_barrel'),
      NamedIcon(text: 'Plantas termoeléctricas', iconName: 'electric_bolt'),
      NamedIcon(text: 'Calderas industriales', iconName: 'hvac'),
      NamedIcon(text: 'Fundición de metales', iconName: 'iron'),
      NamedIcon(text: 'Volcanes', iconName: 'volcano'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(text: 'Obstrucción bronquial', iconName: 'block'),
        NamedIcon(text: 'Hipersecreción bronquial', iconName: 'water_drop'),
      ],
      longTerm: [
        NamedIcon(text: 'Bronquitis crónica', iconName: 'sick'),
      ],
    ),
  ),

  'NO2': PollutantInfo(
    symbol: 'NO2',
    name: 'Dióxido de Nitrógeno',
    description:
        'Molécula con 2 átomos de oxígeno y uno de Nitrógeno que se produce principalmente por la combustión de combustibles fósiles empleados en vehículos y plantas de energía.',
    method: Measurement(method: 'Quimioluminiscencia en fase gaseosa', iconName: 'science'),
    sources: [
      NamedIcon(text: 'Vehículos automotores', iconName: 'directions_car'),
      NamedIcon(text: 'Plantas de generación eléctrica', iconName: 'bolt'),
      NamedIcon(text: 'Hornos industriales', iconName: 'fireplace'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(text: 'Hiperreactividad bronquial', iconName: 'mood_bad'),
        NamedIcon(text: 'Exacerbaciones de asma', iconName: 'medical_services'),
        NamedIcon(text: 'Respuesta a alergenos', iconName: 'coronavirus'),
        NamedIcon(text: 'Disminución mucociliar', iconName: 'filter_drama'),
      ],
      longTerm: [
        NamedIcon(text: 'Decremento desarrollo pulmonar', iconName: 'trending_down'),
      ],
    ),
  ),

  'CO': PollutantInfo(
    symbol: 'CO',
    name: 'Monóxido de Carbono',
    description:
        'Gas incoloro que se forma principalmente por la combustión de gasolinas, leña o carbón, este compuesto, en altas concentraciones puede ser muy nocivo a la salud.',
    method: Measurement(method: 'Fotometría infrarroja', iconName: 'sensors'),
    sources: [
      NamedIcon(text: 'Combustión incompleta en vehículos', iconName: 'no_crash'),
      NamedIcon(text: 'Quema de biomasa y basura', iconName: 'delete_forever'),
      NamedIcon(text: 'Estufas mal ventiladas', iconName: 'kitchen'),
      NamedIcon(text: 'Incendios forestales', iconName: 'forest'),
    ],
    risks: Risks(
      shortTerm: [NamedIcon(text: 'Disminución en capacidad de ejercicio', iconName: 'directions_run')],
      longTerm: [],
    ),
  ),

  'O3': PollutantInfo(
    symbol: 'O3',
    name: 'Ozono',
    description:
        'Gas compuesto por 3 átomos de oxigeno que se encuentra principalmente en la estratosfera, puede formarse a nivel superficial debido a condiciones de alta radiación y temperatura.',
    method: Measurement(method: 'Espectrofotometría UV', iconName: 'light_mode'),
    sources: [NamedIcon(text: 'Reacción química con luz solar', iconName: 'wb_sunny')],
    risks: Risks(
      shortTerm: [
        NamedIcon(text: 'Disminución frecuencia respiratoria', iconName: 'timer'),
        NamedIcon(text: 'Alveolitis neutrofílica', iconName: 'coronavirus'),
        NamedIcon(text: 'Hiperreactividad bronquial', iconName: 'sick'),
        NamedIcon(text: 'Alteración del epitelio alveolar', iconName: 'grid_on'),
      ],
      longTerm: [
        NamedIcon(text: 'Daño de células epiteliales', iconName: 'cell_wifi'),
        NamedIcon(text: 'Bronquiolización alveolar', iconName: 'texture'),
        NamedIcon(text: 'Disminución CVF y VEF1', iconName: 'compress'),
      ],
    ),
  ),
};
