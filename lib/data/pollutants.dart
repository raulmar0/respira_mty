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
  /// Localization key for the measurement method (e.g. 'pollutant_pm10_method')
  final String methodKey;
  final String iconName;

  const Measurement({required this.methodKey, required this.iconName});

  IconData get icon => iconFromName(iconName);
}

class NamedIcon {
  /// Localization key for the text to display (e.g. 'pollutant_pm10_source_resuspended')
  final String textKey;
  final String iconName;

  const NamedIcon({required this.textKey, required this.iconName});

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
    method: Measurement(methodKey: 'pm10_method', iconName: 'science'),
    sources: [
      NamedIcon(textKey: 'pm10_source_resuspended', iconName: 'grain'),
      NamedIcon(textKey: 'pm10_source_construction', iconName: 'construction'),
      NamedIcon(textKey: 'pm10_source_mining', iconName: 'landscape'),
      NamedIcon(textKey: 'pm10_source_fuel_burning', iconName: 'local_gas_station'),
      NamedIcon(textKey: 'pm10_source_erosion', iconName: 'terrain'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(textKey: 'pm10_risk_morbidity', iconName: 'local_hospital'),
        NamedIcon(textKey: 'pm10_risk_function', iconName: 'air'),
        NamedIcon(textKey: 'pm10_risk_defense', iconName: 'shield'),
        NamedIcon(textKey: 'pm10_risk_bronchial', iconName: 'block'),
      ],
      longTerm: [
        NamedIcon(textKey: 'pm10_risk_development', iconName: 'child_care'),
        NamedIcon(textKey: 'pm10_risk_cancer', iconName: 'warning'),
      ],
    ),
  ),

  'PM25': PollutantInfo(
    symbol: 'PM25',
    name: 'Material Particulado menor a 2.5 micrómetros',
    description:
        'Mezcla Compleja de Partículas líquidas o sólidas que provienen principalmente de fuentes antropogénicas, poseen un tamaño aerodinámico menor a 2.5 micrómetros.',
    method: Measurement(methodKey: 'pm25_method', iconName: 'science'),
    sources: [
      NamedIcon(textKey: 'pm25_source_vehicle_combustion', iconName: 'directions_bus'),
      NamedIcon(textKey: 'pm25_source_industry', iconName: 'factory'),
      NamedIcon(textKey: 'pm25_source_agricultural_burn', iconName: 'agriculture'),
      NamedIcon(textKey: 'pm25_source_wildfires', iconName: 'forest'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(textKey: 'pm25_risk_morbidity', iconName: 'local_hospital'),
        NamedIcon(textKey: 'pm25_risk_function', iconName: 'air'),
        NamedIcon(textKey: 'pm25_risk_defense', iconName: 'shield'),
        NamedIcon(textKey: 'pm25_risk_bronchial', iconName: 'block'),
      ],
      longTerm: [
        NamedIcon(textKey: 'pm25_risk_development', iconName: 'child_care'),
        NamedIcon(textKey: 'pm25_risk_cancer', iconName: 'warning'),
      ],
    ),
  ),

  'SO2': PollutantInfo(
    symbol: 'SO2',
    name: 'Dióxido de Azufre',
    description:
        'Gas formado por 2 átomos de oxígeno y uno de azufre, se forma principalmente por la combustión de combustibles fósiles con alto contenido de azufre.',
    method: Measurement(methodKey: 'so2_method', iconName: 'light_mode'),
    sources: [
      NamedIcon(textKey: 'so2_source_refineries', iconName: 'oil_barrel'),
      NamedIcon(textKey: 'so2_source_power_plants', iconName: 'electric_bolt'),
      NamedIcon(textKey: 'so2_source_boilers', iconName: 'hvac'),
      NamedIcon(textKey: 'so2_source_metal_smelting', iconName: 'iron'),
      NamedIcon(textKey: 'so2_source_volcanoes', iconName: 'volcano'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(textKey: 'so2_risk_obstruction', iconName: 'block'),
        NamedIcon(textKey: 'so2_risk_hypersecretion', iconName: 'water_drop'),
      ],
      longTerm: [
        NamedIcon(textKey: 'so2_risk_chronic_bronchitis', iconName: 'sick'),
      ],
    ),
  ),

  'NO2': PollutantInfo(
    symbol: 'NO2',
    name: 'Dióxido de Nitrógeno',
    description:
        'Molécula con 2 átomos de oxígeno y uno de Nitrógeno que se produce principalmente por la combustión de combustibles fósiles empleados en vehículos y plantas de energía.',
    method: Measurement(methodKey: 'no2_method', iconName: 'science'),
    sources: [
      NamedIcon(textKey: 'no2_source_vehicles', iconName: 'directions_car'),
      NamedIcon(textKey: 'no2_source_power_plants', iconName: 'bolt'),
      NamedIcon(textKey: 'no2_source_industrial_ovens', iconName: 'fireplace'),
    ],
    risks: Risks(
      shortTerm: [
        NamedIcon(textKey: 'no2_risk_hyperreactivity', iconName: 'mood_bad'),
        NamedIcon(textKey: 'no2_risk_asthma_exacerbations', iconName: 'medical_services'),
        NamedIcon(textKey: 'no2_risk_allergen_response', iconName: 'coronavirus'),
        NamedIcon(textKey: 'no2_risk_mucociliary', iconName: 'filter_drama'),
      ],
      longTerm: [
        NamedIcon(textKey: 'no2_risk_development_decrement', iconName: 'trending_down'),
      ],
    ),
  ),

  'CO': PollutantInfo(
    symbol: 'CO',
    name: 'Monóxido de Carbono',
    description:
        'Gas incoloro que se forma principalmente por la combustión de gasolinas, leña o carbón, este compuesto, en altas concentraciones puede ser muy nocivo a la salud.',
    method: Measurement(methodKey: 'co_method', iconName: 'sensors'),
    sources: [
      NamedIcon(textKey: 'co_source_incomplete_combustion', iconName: 'no_crash'),
      NamedIcon(textKey: 'co_source_biomass_burning', iconName: 'delete_forever'),
      NamedIcon(textKey: 'co_source_poorly_vented_stoves', iconName: 'kitchen'),
      NamedIcon(textKey: 'co_source_wildfires', iconName: 'forest'),
    ],
    risks: Risks(
      shortTerm: [NamedIcon(textKey: 'co_risk_exercise_capacity', iconName: 'directions_run')],
      longTerm: [],
    ),
  ),

  'O3': PollutantInfo(
    symbol: 'O3',
    name: 'Ozono',
    description:
        'Gas compuesto por 3 átomos de oxigeno que se encuentra principalmente en la estratosfera, puede formarse a nivel superficial debido a condiciones de alta radiación y temperatura.',
    method: Measurement(methodKey: 'o3_method', iconName: 'light_mode'),
    sources: [NamedIcon(textKey: 'o3_source_photochemical_reaction', iconName: 'wb_sunny')],
    risks: Risks(
      shortTerm: [
        NamedIcon(textKey: 'o3_risk_reduced_resp_rate', iconName: 'timer'),
        NamedIcon(textKey: 'o3_risk_alveolitis', iconName: 'coronavirus'),
        NamedIcon(textKey: 'o3_risk_hyperreactivity', iconName: 'sick'),
        NamedIcon(textKey: 'o3_risk_alveolar_epithelium', iconName: 'grid_on'),
      ],
      longTerm: [
        NamedIcon(textKey: 'o3_risk_epithelial_damage', iconName: 'cell_wifi'),
        NamedIcon(textKey: 'o3_risk_bronchiolization', iconName: 'texture'),
        NamedIcon(textKey: 'o3_risk_decreased_cvf_vef1', iconName: 'compress'),
      ],
    ),
  ),
};
