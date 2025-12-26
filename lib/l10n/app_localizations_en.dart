// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Respira MTY';

  @override
  String get stationsMapTitle => 'Stations Map';

  @override
  String get stationsTitle => 'Stations';

  @override
  String get errorLoadingAirQuality => 'Could not load air quality. Check your connection.';

  @override
  String get searchHint => 'Search station…';

  @override
  String lastUpdatedPrefix(Object time) {
    return 'LAST UPDATED: $time';
  }

  @override
  String get lastUpdatedUnknown => 'LAST UPDATED: —';

  @override
  String get noFavorites => 'No favorites selected';

  @override
  String get favoriteHint => 'Tap the heart on stations to see them here.';

  @override
  String get updatingStations => 'Updating stations...';

  @override
  String stationsUpdated(Object count) {
    return 'Stations updated: $count';
  }

  @override
  String updatingError(Object error) {
    return 'Error updating stations: $error';
  }

  @override
  String get updateStationsTooltip => 'Update stations';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get temperatureNow => 'Current Temperature';

  @override
  String get partlyCloudy => 'Partly cloudy';

  @override
  String get pm10 => 'Particulate Matter PM10';

  @override
  String get pm2_5 => 'Particulate Matter PM2.5';

  @override
  String get no2 => 'Nitrogen Dioxide';

  @override
  String get so2 => 'Sulfur Dioxide';

  @override
  String get co => 'Carbon Monoxide';

  @override
  String get o3 => 'Ozone';

  @override
  String pollutantDetail(Object label) {
    return 'Detail: $label';
  }

  @override
  String get pollutantDetailTitle => 'Detail';

  @override
  String get measurementMethod => 'Measurement Method';

  @override
  String get shortTerm => 'Short-term';

  @override
  String get longTerm => 'Long-term';

  @override
  String get dataUnavailable => 'Data unavailable';

  @override
  String get pm25_desc => 'Fine inhalable particles with aerodynamic diameters of 2.5 micrometers or less.';

  @override
  String get pm10_desc => 'Inhalable particles with diameters of 10 micrometers or less.';

  @override
  String get o3_desc => 'Tropospheric ozone, a respiratory irritant that can worsen breathing problems.';

  @override
  String get no2_desc => 'Nitrogen dioxide, can cause irritation and worsen respiratory illnesses.';

  @override
  String get so2_desc => 'Sulfur dioxide, can irritate airways and aggravate asthma.';

  @override
  String get co_desc => 'Carbon monoxide, reduces the blood\'s ability to carry oxygen.';

  @override
  String get genericPollutantInfo => 'Information about this pollutant.';

  @override
  String get pm10_method => 'Beta attenuation and white light scattering';

  @override
  String get pm10_source_resuspended => 'Resuspended road dust';

  @override
  String get pm10_source_construction => 'Construction activities';

  @override
  String get pm10_source_mining => 'Mining and quarrying';

  @override
  String get pm10_source_fuel_burning => 'Fuel burning';

  @override
  String get pm10_source_erosion => 'Soil erosion';

  @override
  String get pm10_risk_morbidity => 'Increased respiratory morbidity and mortality';

  @override
  String get pm10_risk_function => 'Reduced lung function';

  @override
  String get pm10_risk_defense => 'Interference with pulmonary defense mechanisms';

  @override
  String get pm10_risk_bronchial => 'Bronchial obstructive syndrome';

  @override
  String get pm10_risk_development => 'Impaired respiratory system development';

  @override
  String get pm10_risk_cancer => 'Increased risk of cancer (PAHs)';

  @override
  String get pm25_method => 'Beta attenuation and white light scattering';

  @override
  String get pm25_source_vehicle_combustion => 'Vehicle combustion (diesel)';

  @override
  String get pm25_source_industry => 'Industrial processes';

  @override
  String get pm25_source_agricultural_burn => 'Agricultural burning';

  @override
  String get pm25_source_wildfires => 'Wildfires';

  @override
  String get pm25_risk_morbidity => 'Increased respiratory morbidity and mortality';

  @override
  String get pm25_risk_function => 'Reduced lung function';

  @override
  String get pm25_risk_defense => 'Interference with pulmonary defense mechanisms';

  @override
  String get pm25_risk_bronchial => 'Bronchial obstructive syndrome';

  @override
  String get pm25_risk_development => 'Impaired respiratory system development';

  @override
  String get pm25_risk_cancer => 'Increased risk of cancer (PAHs)';

  @override
  String get so2_method => 'Pulsed UV fluorescence';

  @override
  String get so2_source_refineries => 'Oil refineries';

  @override
  String get so2_source_power_plants => 'Power plants';

  @override
  String get so2_source_boilers => 'Industrial boilers';

  @override
  String get so2_source_metal_smelting => 'Metal smelting';

  @override
  String get so2_source_volcanoes => 'Volcanoes';

  @override
  String get so2_risk_obstruction => 'Bronchial obstruction';

  @override
  String get so2_risk_hypersecretion => 'Bronchial hypersecretion';

  @override
  String get so2_risk_chronic_bronchitis => 'Chronic bronchitis';

  @override
  String get no2_method => 'Gas-phase chemiluminescence';

  @override
  String get no2_source_vehicles => 'Motor vehicles';

  @override
  String get no2_source_power_plants => 'Power generation plants';

  @override
  String get no2_source_industrial_ovens => 'Industrial furnaces';

  @override
  String get no2_risk_hyperreactivity => 'Bronchial hyperreactivity';

  @override
  String get no2_risk_asthma_exacerbations => 'Asthma exacerbations';

  @override
  String get no2_risk_allergen_response => 'Allergen response';

  @override
  String get no2_risk_mucociliary => 'Mucociliary decrement';

  @override
  String get no2_risk_development_decrement => 'Decreased developmental lung function';

  @override
  String get co_method => 'Infrared photometry';

  @override
  String get co_source_incomplete_combustion => 'Incomplete combustion in vehicles';

  @override
  String get co_source_biomass_burning => 'Biomass and waste burning';

  @override
  String get co_source_poorly_vented_stoves => 'Poorly ventilated stoves';

  @override
  String get co_source_wildfires => 'Wildfires';

  @override
  String get co_risk_exercise_capacity => 'Reduced exercise capacity';

  @override
  String get o3_method => 'UV spectrophotometry';

  @override
  String get o3_source_photochemical_reaction => 'Photochemical reaction with sunlight';

  @override
  String get o3_risk_reduced_resp_rate => 'Decreased respiratory rate';

  @override
  String get o3_risk_alveolitis => 'Neutrophilic alveolitis';

  @override
  String get o3_risk_hyperreactivity => 'Bronchial hyperreactivity';

  @override
  String get o3_risk_alveolar_epithelium => 'Alteration of alveolar epithelium';

  @override
  String get o3_risk_epithelial_damage => 'Epithelial cell damage';

  @override
  String get o3_risk_bronchiolization => 'Bronchiolization';

  @override
  String get o3_risk_decreased_cvf_vef1 => 'Decreased CVF and VEF1';

  @override
  String get risksTitle => 'Risks';

  @override
  String get respiratoryProblems => 'Respiratory problems';

  @override
  String get respiratoryProblemsDesc => 'Short-term exposure can irritate the lungs and cause coughing or difficulty breathing.';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get vehicleEmissions => 'Vehicle emissions';

  @override
  String get vehicleEmissionsDesc => 'Cars, trucks and buses.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get tabPollutants => 'Pollutants';

  @override
  String get tabWeather => 'Weather';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String optionSelected(Object option) {
    return '$option selected';
  }

  @override
  String errorLoadingTheme(Object error) {
    return 'Error loading theme: $error';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterAlerts => 'Alerts';

  @override
  String get notifFilterSystem => 'System';

  @override
  String get notifFilterTips => 'Tips';

  @override
  String get today => 'TODAY';

  @override
  String get yesterday => 'YESTERDAY';

  @override
  String get notifAirQualityBadTitle => 'Air quality: Poor';

  @override
  String get notifAirQualityBadBody => 'PM2.5 levels have risen sharply in the San Pedro area. Consider using masks and limiting outdoor activity.';

  @override
  String get notifRainForecastTitle => 'Rain forecast';

  @override
  String get notifRainForecastBody => 'Light rain is expected in the coming hours which could help clear the air.';

  @override
  String get notifNewStationTitle => 'New station added';

  @override
  String get notifNewStationBody => 'We now monitor air quality in Santa Catarina.';

  @override
  String get notifHealthTipTitle => 'Health recommendation';

  @override
  String get notifHealthTipBody => 'Pollen levels are high. Avoid outdoor activities if you are allergic.';

  @override
  String get versionLabel => 'Version 1.0.2';

  @override
  String get dataProviderCredit => 'Data provided by SIMA N.L.';

  @override
  String get notificationsHeader => 'NOTIFICATIONS';

  @override
  String get criticalAlertsTitle => 'Critical Alerts';

  @override
  String get criticalAlertsSubtitle => 'Notify when air quality is dangerous';

  @override
  String get alertsEnabled => 'Critical alerts enabled';

  @override
  String get alertsDisabled => 'Critical alerts disabled';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDescription => 'Choose the language for the app interface.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get sortPlusQuality => 'High quality first';

  @override
  String get sortMinusQuality => 'Low quality first';

  @override
  String get sortAToZ => 'A → Z';

  @override
  String get sortZToA => 'Z → A';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get infoHeader => 'INFORMATION';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutApp => 'About the App';

  @override
  String get visualizationHeader => 'VISUALIZATION';

  @override
  String get filterAll => 'All Stations';

  @override
  String get filterGood => 'Good';

  @override
  String get filterModerate => 'Moderate';

  @override
  String get filterUnhealthy => 'Unhealthy';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get filterNearest => 'Nearest';

  @override
  String get airQualityGood => 'Good';

  @override
  String get airQualityAcceptable => 'Acceptable';

  @override
  String get airQualityBad => 'Bad';

  @override
  String get airQualityVeryBad => 'Very bad';

  @override
  String get airQualityExtremelyBad => 'Extremely bad';

  @override
  String get airQualityUnknown => 'Unknown';
}
