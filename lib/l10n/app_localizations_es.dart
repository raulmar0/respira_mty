// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Respira MTY';

  @override
  String get stationsMapTitle => 'Mapa de Estaciones';

  @override
  String get stationsTitle => 'Estaciones';

  @override
  String get errorLoadingAirQuality => 'No se pudo cargar la calidad del aire. Revisa tu conexión.';

  @override
  String get searchHint => 'Buscar estación…';

  @override
  String lastUpdatedPrefix(Object time) {
    return 'ULTIMA ACTUALIZACIÓN: $time';
  }

  @override
  String get lastUpdatedUnknown => 'ULTIMA ACTUALIZACIÓN: —';

  @override
  String get noFavorites => 'No hay favoritos seleccionados';

  @override
  String get favoriteHint => 'Marca estaciones con el corazón para verlas aquí.';

  @override
  String get updatingStations => 'Actualizando estaciones...';

  @override
  String stationsUpdated(Object count) {
    return 'Estaciones actualizadas: $count';
  }

  @override
  String updatingError(Object error) {
    return 'Error al actualizar estaciones: $error';
  }

  @override
  String get updateStationsTooltip => 'Actualizar estaciones';

  @override
  String get goToSettings => 'Ir a Ajustes';

  @override
  String get temperatureNow => 'Temperatura Actual';

  @override
  String get partlyCloudy => 'Parcialmente nublado';

  @override
  String get pm10 => 'Partículas PM10';

  @override
  String get pm2_5 => 'Partículas PM2.5';

  @override
  String get no2 => 'Dióxido de Nitrógeno';

  @override
  String get so2 => 'Dióxido de Azufre';

  @override
  String get co => 'Monóxido de Carbono';

  @override
  String get o3 => 'Ozono';

  @override
  String pollutantDetail(Object label) {
    return 'Detalle: $label';
  }

  @override
  String get pollutantDetailTitle => 'Detalle';

  @override
  String get measurementMethod => 'Método de medición';

  @override
  String get shortTerm => 'A corto plazo';

  @override
  String get longTerm => 'A largo plazo';

  @override
  String get dataUnavailable => 'Datos no disponibles';

  @override
  String get pm25_desc => 'Partículas finas inhalables con diámetros de 2.5 micrómetros o menos.';

  @override
  String get pm10_desc => 'Partículas inhalables con diámetros de 10 micrómetros o menos.';

  @override
  String get o3_desc => 'Ozono troposférico, irritante respiratorio que puede agravar problemas respiratorios.';

  @override
  String get no2_desc => 'Dióxido de nitrógeno, puede causar irritación y empeorar enfermedades respiratorias.';

  @override
  String get so2_desc => 'Dióxido de azufre, puede irritar las vías respiratorias y agravar el asma.';

  @override
  String get co_desc => 'Monóxido de carbono, reduce la capacidad de la sangre para transportar oxígeno.';

  @override
  String get genericPollutantInfo => 'Información sobre este contaminante.';

  @override
  String get pm10_method => 'Atenuación de rayos Beta y Dispersión de luz blanca';

  @override
  String get pm10_source_resuspended => 'Polvo resuspendido en calles';

  @override
  String get pm10_source_construction => 'Actividades de construcción';

  @override
  String get pm10_source_mining => 'Industria extractiva (pedreras)';

  @override
  String get pm10_source_fuel_burning => 'Quema de combustibles';

  @override
  String get pm10_source_erosion => 'Erosión del suelo';

  @override
  String get pm10_risk_morbidity => 'Aumento de morbimortalidad respiratoria';

  @override
  String get pm10_risk_function => 'Disminución en la función pulmonar';

  @override
  String get pm10_risk_defense => 'Interferencia en mecanismos de defensa pulmonar';

  @override
  String get pm10_risk_bronchial => 'Síndrome bronquial obstructivo';

  @override
  String get pm10_risk_development => 'Menor desarrollo del sistema respiratorio';

  @override
  String get pm10_risk_cancer => 'Mayor riesgo de cáncer (HAPs)';

  @override
  String get pm25_method => 'Atenuación de rayos Beta y Dispersión de luz blanca';

  @override
  String get pm25_source_vehicle_combustion => 'Combustión de vehículos (diésel)';

  @override
  String get pm25_source_industry => 'Procesos industriales';

  @override
  String get pm25_source_agricultural_burn => 'Quemas agrícolas';

  @override
  String get pm25_source_wildfires => 'Incendios forestales';

  @override
  String get pm25_risk_morbidity => 'Aumento de morbimortalidad respiratoria';

  @override
  String get pm25_risk_function => 'Disminución en la función pulmonar';

  @override
  String get pm25_risk_defense => 'Interferencia en mecanismos de defensa pulmonar';

  @override
  String get pm25_risk_bronchial => 'Síndrome bronquial obstructivo';

  @override
  String get pm25_risk_development => 'Menor desarrollo del sistema respiratorio';

  @override
  String get pm25_risk_cancer => 'Mayor riesgo de cáncer (HAPs)';

  @override
  String get so2_method => 'Fluorescencia pulsante UV';

  @override
  String get so2_source_refineries => 'Refinerías de petróleo';

  @override
  String get so2_source_power_plants => 'Plantas termoeléctricas';

  @override
  String get so2_source_boilers => 'Calderas industriales';

  @override
  String get so2_source_metal_smelting => 'Fundición de metales';

  @override
  String get so2_source_volcanoes => 'Volcanes';

  @override
  String get so2_risk_obstruction => 'Obstrucción bronquial';

  @override
  String get so2_risk_hypersecretion => 'Hipersecreción bronquial';

  @override
  String get so2_risk_chronic_bronchitis => 'Bronquitis crónica';

  @override
  String get no2_method => 'Quimioluminiscencia en fase gaseosa';

  @override
  String get no2_source_vehicles => 'Vehículos automotores';

  @override
  String get no2_source_power_plants => 'Plantas de generación eléctrica';

  @override
  String get no2_source_industrial_ovens => 'Hornos industriales';

  @override
  String get no2_risk_hyperreactivity => 'Hiperreactividad bronquial';

  @override
  String get no2_risk_asthma_exacerbations => 'Exacerbaciones de asma';

  @override
  String get no2_risk_allergen_response => 'Respuesta a alergenos';

  @override
  String get no2_risk_mucociliary => 'Disminución mucociliar';

  @override
  String get no2_risk_development_decrement => 'Decremento desarrollo pulmonar';

  @override
  String get co_method => 'Fotometría infrarroja';

  @override
  String get co_source_incomplete_combustion => 'Combustión incompleta en vehículos';

  @override
  String get co_source_biomass_burning => 'Quema de biomasa y basura';

  @override
  String get co_source_poorly_vented_stoves => 'Estufas mal ventiladas';

  @override
  String get co_source_wildfires => 'Incendios forestales';

  @override
  String get co_risk_exercise_capacity => 'Disminución en capacidad de ejercicio';

  @override
  String get o3_method => 'Espectrofotometría UV';

  @override
  String get o3_source_photochemical_reaction => 'Reacción fotoquímica con luz solar';

  @override
  String get o3_risk_reduced_resp_rate => 'Disminución frecuencia respiratoria';

  @override
  String get o3_risk_alveolitis => 'Alveolitis neutrofílica';

  @override
  String get o3_risk_hyperreactivity => 'Hiperreactividad bronquial';

  @override
  String get o3_risk_alveolar_epithelium => 'Alteración del epitelio alveolar';

  @override
  String get o3_risk_epithelial_damage => 'Daño de células epiteliales';

  @override
  String get o3_risk_bronchiolization => 'Bronquiolización alveolar';

  @override
  String get o3_risk_decreased_cvf_vef1 => 'Disminución CVF y VEF1';

  @override
  String get risksTitle => 'Riesgos';

  @override
  String get respiratoryProblems => 'Problemas Respiratorios';

  @override
  String get respiratoryProblemsDesc => 'La exposición a corto plazo puede irritar los pulmones y causar tos o dificultad para respirar.';

  @override
  String get sourcesTitle => 'Fuentes';

  @override
  String get vehicleEmissions => 'Emisiones de Vehículos';

  @override
  String get vehicleEmissionsDesc => 'Automóviles, camiones y autobuses.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get tabPollutants => 'Contaminantes';

  @override
  String get tabWeather => 'Clima';

  @override
  String get forecastTitle => 'Pronóstico';

  @override
  String optionSelected(Object option) {
    return '$option seleccionado';
  }

  @override
  String errorLoadingTheme(Object error) {
    return 'Error al cargar el tema: $error';
  }

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get markAllRead => 'Marcar leídos';

  @override
  String get notifFilterAll => 'Todas';

  @override
  String get notifFilterAlerts => 'Alertas';

  @override
  String get notifFilterSystem => 'Sistema';

  @override
  String get notifFilterTips => 'Consejos';

  @override
  String get today => 'HOY';

  @override
  String get yesterday => 'AYER';

  @override
  String get notifAirQualityBadTitle => 'Calidad del aire: Mala';

  @override
  String get notifAirQualityBadBody => 'El nivel de PM2.5 ha subido drásticamente en la zona de San Pedro. Se recomienda usar mascarilla y limitar actividades al aire libre.';

  @override
  String get notifRainForecastTitle => 'Pronóstico de lluvia';

  @override
  String get notifRainForecastBody => 'Se espera lluvia ligera en las próximas horas que podría ayudar a limpiar el aire.';

  @override
  String get notifNewStationTitle => 'Nueva estación añadida';

  @override
  String get notifNewStationBody => 'Ahora monitoreamos la calidad del aire en la zona de Santa Catarina.';

  @override
  String get notifHealthTipTitle => 'Recomendación de salud';

  @override
  String get notifHealthTipBody => 'Los niveles de polen son altos. Evita actividades al aire libre si eres alérgico.';

  @override
  String get versionLabel => 'Versión 1.0.2';

  @override
  String get dataProviderCredit => 'Datos provistos por SIMA N.L.';

  @override
  String get notificationsHeader => 'NOTIFICACIONES';

  @override
  String get criticalAlertsTitle => 'Alertas Críticas';

  @override
  String get criticalAlertsSubtitle => 'Notificar cuando el aire sea peligroso';

  @override
  String get alertsEnabled => 'Alertas críticas activadas';

  @override
  String get alertsDisabled => 'Alertas críticas desactivadas';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageDescription => 'Elige el idioma para la interfaz de la aplicación.';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get sortPlusQuality => '+ Calidad';

  @override
  String get sortMinusQuality => '- Calidad';

  @override
  String get sortAToZ => 'A → Z';

  @override
  String get sortZToA => 'Z → A';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get infoHeader => 'INFORMACIÓN';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get aboutApp => 'Acerca de la App';

  @override
  String get visualizationHeader => 'VISUALIZACIÓN';

  @override
  String get filterAll => 'Todas las estaciones';

  @override
  String get filterGood => 'Buena';

  @override
  String get filterModerate => 'Aceptable';

  @override
  String get filterUnhealthy => 'Mala';

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get filterNearest => 'Cercanas';

  @override
  String get airQualityGood => 'Calidad Buena';

  @override
  String get airQualityAcceptable => 'Calidad Aceptable';

  @override
  String get airQualityBad => 'Calidad Mala';

  @override
  String get airQualityVeryBad => 'Calidad Muy Mala';

  @override
  String get airQualityExtremelyBad => 'Calidad Extremadamente Mala';

  @override
  String get airQualityUnknown => 'Calidad Desconocida';

  @override
  String get shareSuccess => 'Compartido';

  @override
  String get shareError => 'Error al compartir';

  @override
  String shareText(Object name) {
    return 'Compartiendo estación $name';
  }
}
