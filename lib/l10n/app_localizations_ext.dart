import 'package:respira_mty/l10n/app_localizations.dart';

extension AppLocalizationsExt on AppLocalizations {
  /// Translate a dynamic key used in data maps (e.g., pollutant source/risk/method keys)
  /// Falls back to `genericPollutantInfo` if the key is unknown.
  String translateKey(String key) {
    switch (key) {
      // PM10
      case 'pm10_method':
        return pm10_method;
      case 'pm10_source_resuspended':
        return pm10_source_resuspended;
      case 'pm10_source_construction':
        return pm10_source_construction;
      case 'pm10_source_mining':
        return pm10_source_mining;
      case 'pm10_source_fuel_burning':
        return pm10_source_fuel_burning;
      case 'pm10_source_erosion':
        return pm10_source_erosion;
      case 'pm10_risk_morbidity':
        return pm10_risk_morbidity;
      case 'pm10_risk_function':
        return pm10_risk_function;
      case 'pm10_risk_defense':
        return pm10_risk_defense;
      case 'pm10_risk_bronchial':
        return pm10_risk_bronchial;
      case 'pm10_risk_development':
        return pm10_risk_development;
      case 'pm10_risk_cancer':
        return pm10_risk_cancer;

      // PM2.5
      case 'pm25_method':
        return pm25_method;
      case 'pm25_source_vehicle_combustion':
        return pm25_source_vehicle_combustion;
      case 'pm25_source_industry':
        return pm25_source_industry;
      case 'pm25_source_agricultural_burn':
        return pm25_source_agricultural_burn;
      case 'pm25_source_wildfires':
        return pm25_source_wildfires;
      case 'pm25_risk_morbidity':
        return pm25_risk_morbidity;
      case 'pm25_risk_function':
        return pm25_risk_function;
      case 'pm25_risk_defense':
        return pm25_risk_defense;
      case 'pm25_risk_bronchial':
        return pm25_risk_bronchial;
      case 'pm25_risk_development':
        return pm25_risk_development;
      case 'pm25_risk_cancer':
        return pm25_risk_cancer;

      // SO2
      case 'so2_method':
        return so2_method;
      case 'so2_source_refineries':
        return so2_source_refineries;
      case 'so2_source_power_plants':
        return so2_source_power_plants;
      case 'so2_source_boilers':
        return so2_source_boilers;
      case 'so2_source_metal_smelting':
        return so2_source_metal_smelting;
      case 'so2_source_volcanoes':
        return so2_source_volcanoes;
      case 'so2_risk_obstruction':
        return so2_risk_obstruction;
      case 'so2_risk_hypersecretion':
        return so2_risk_hypersecretion;
      case 'so2_risk_chronic_bronchitis':
        return so2_risk_chronic_bronchitis;

      // NO2
      case 'no2_method':
        return no2_method;
      case 'no2_source_vehicles':
        return no2_source_vehicles;
      case 'no2_source_power_plants':
        return no2_source_power_plants;
      case 'no2_source_industrial_ovens':
        return no2_source_industrial_ovens;
      case 'no2_risk_hyperreactivity':
        return no2_risk_hyperreactivity;
      case 'no2_risk_asthma_exacerbations':
        return no2_risk_asthma_exacerbations;
      case 'no2_risk_allergen_response':
        return no2_risk_allergen_response;
      case 'no2_risk_mucociliary':
        return no2_risk_mucociliary;
      case 'no2_risk_development_decrement':
        return no2_risk_development_decrement;

      // CO
      case 'co_method':
        return co_method;
      case 'co_source_incomplete_combustion':
        return co_source_incomplete_combustion;
      case 'co_source_biomass_burning':
        return co_source_biomass_burning;
      case 'co_source_poorly_vented_stoves':
        return co_source_poorly_vented_stoves;
      case 'co_source_wildfires':
        return co_source_wildfires;
      case 'co_risk_exercise_capacity':
        return co_risk_exercise_capacity;

      // O3
      case 'o3_method':
        return o3_method;
      case 'o3_source_photochemical_reaction':
        return o3_source_photochemical_reaction;
      case 'o3_risk_reduced_resp_rate':
        return o3_risk_reduced_resp_rate;
      case 'o3_risk_alveolitis':
        return o3_risk_alveolitis;
      case 'o3_risk_hyperreactivity':
        return o3_risk_hyperreactivity;
      case 'o3_risk_alveolar_epithelium':
        return o3_risk_alveolar_epithelium;
      case 'o3_risk_epithelial_damage':
        return o3_risk_epithelial_damage;
      case 'o3_risk_bronchiolization':
        return o3_risk_bronchiolization;
      case 'o3_risk_decreased_cvf_vef1':
        return o3_risk_decreased_cvf_vef1;

      default:
        return genericPollutantInfo;
    }
  }
}