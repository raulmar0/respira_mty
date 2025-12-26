// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Respira MTY';

  @override
  String get stationsMapTitle => 'Carte des stations';

  @override
  String get stationsTitle => 'Stations';

  @override
  String get errorLoadingAirQuality => 'Impossible de charger la qualité de l\'air. Vérifiez votre connexion.';

  @override
  String get searchHint => 'Rechercher une station…';

  @override
  String lastUpdatedPrefix(Object time) {
    return 'DERNIÈRE MISE À JOUR : $time';
  }

  @override
  String get lastUpdatedUnknown => 'DERNIÈRE MISE À JOUR : —';

  @override
  String get noFavorites => 'Aucun favori sélectionné';

  @override
  String get favoriteHint => 'Touchez le cœur sur les stations pour les voir ici.';

  @override
  String get updatingStations => 'Mise à jour des stations...';

  @override
  String stationsUpdated(Object count) {
    return 'Stations mises à jour : $count';
  }

  @override
  String updatingError(Object error) {
    return 'Erreur lors de la mise à jour des stations: $error';
  }

  @override
  String get updateStationsTooltip => 'Mettre à jour les stations';

  @override
  String get goToSettings => 'Aller aux paramètres';

  @override
  String get temperatureNow => 'Température actuelle';

  @override
  String get partlyCloudy => 'Partiellement nuageux';

  @override
  String get pm10 => 'Particules PM10';

  @override
  String get pm2_5 => 'Particules PM2.5';

  @override
  String get no2 => 'Dioxyde d\'azote';

  @override
  String get so2 => 'Dioxyde de soufre';

  @override
  String get co => 'Monoxyde de carbone';

  @override
  String get o3 => 'Ozone';

  @override
  String pollutantDetail(Object label) {
    return 'Détail : $label';
  }

  @override
  String get pollutantDetailTitle => 'Détail';

  @override
  String get measurementMethod => 'Méthode de mesure';

  @override
  String get shortTerm => 'Court terme';

  @override
  String get longTerm => 'Long terme';

  @override
  String get dataUnavailable => 'Données indisponibles';

  @override
  String get pm25_desc => 'Particules inhalables fines de diamètre aérodynamique de 2,5 micromètres ou moins.';

  @override
  String get pm10_desc => 'Particules inhalables de diamètre de 10 micromètres ou moins.';

  @override
  String get o3_desc => 'Ozone troposphérique, irritant respiratoire qui peut aggraver les problèmes respiratoires.';

  @override
  String get no2_desc => 'Dioxyde d\'azote, peut provoquer une irritation et aggraver les maladies respiratoires.';

  @override
  String get so2_desc => 'Dioxyde de soufre, peut irriter les voies respiratoires et aggraver l\'asthme.';

  @override
  String get co_desc => 'Monoxyde de carbone, réduit la capacité du sang à transporter l\'oxygène.';

  @override
  String get genericPollutantInfo => 'Informations sur ce polluant.';

  @override
  String get pm10_method => 'Atenuación de rayos Beta y Dispersión de luz blanca';

  @override
  String get pm10_source_resuspended => 'Poussière routière remise en suspension';

  @override
  String get pm10_source_construction => 'Activités de construction';

  @override
  String get pm10_source_mining => 'Extraction minière (carrières)';

  @override
  String get pm10_source_fuel_burning => 'Combustion de combustibles';

  @override
  String get pm10_source_erosion => 'Érosion du sol';

  @override
  String get pm10_risk_morbidity => 'Augmentation de la morbidité et mortalité respiratoires';

  @override
  String get pm10_risk_function => 'Diminution de la fonction pulmonaire';

  @override
  String get pm10_risk_defense => 'Interférence avec les mécanismes de défense pulmonaires';

  @override
  String get pm10_risk_bronchial => 'Syndrome obstructif bronchique';

  @override
  String get pm10_risk_development => 'Développement respiratoire altéré';

  @override
  String get pm10_risk_cancer => 'Augmentation du risque de cancer (HAP)';

  @override
  String get pm25_method => 'Atenuación de rayos Beta y Dispersión de luz blanca';

  @override
  String get pm25_source_vehicle_combustion => 'Combustion des véhicules (diesel)';

  @override
  String get pm25_source_industry => 'Processus industriels';

  @override
  String get pm25_source_agricultural_burn => 'Brûlages agricoles';

  @override
  String get pm25_source_wildfires => 'Feux de forêt';

  @override
  String get pm25_risk_morbidity => 'Augmentation de la morbidité et mortalité respiratoires';

  @override
  String get pm25_risk_function => 'Diminution de la fonction pulmonaire';

  @override
  String get pm25_risk_defense => 'Interférence avec les mécanismes de défense pulmonaires';

  @override
  String get pm25_risk_bronchial => 'Syndrome obstructif bronchique';

  @override
  String get pm25_risk_development => 'Développement respiratoire altéré';

  @override
  String get pm25_risk_cancer => 'Augmentation du risque de cancer (HAP)';

  @override
  String get so2_method => 'Fluorescence UV pulsée';

  @override
  String get so2_source_refineries => 'Raffineries de pétrole';

  @override
  String get so2_source_power_plants => 'Centrales électriques';

  @override
  String get so2_source_boilers => 'Chaudières industrielles';

  @override
  String get so2_source_metal_smelting => 'Fonderie métallique';

  @override
  String get so2_source_volcanoes => 'Volcans';

  @override
  String get so2_risk_obstruction => 'Obstruction bronchique';

  @override
  String get so2_risk_hypersecretion => 'Hypersecrétion bronchique';

  @override
  String get so2_risk_chronic_bronchitis => 'Bronchite chronique';

  @override
  String get no2_method => 'Chimiluminescence en phase gazeuse';

  @override
  String get no2_source_vehicles => 'Véhicules à moteur';

  @override
  String get no2_source_power_plants => 'Centrales de production d\'électricité';

  @override
  String get no2_source_industrial_ovens => 'Fours industriels';

  @override
  String get no2_risk_hyperreactivity => 'Hyperréactivité bronchique';

  @override
  String get no2_risk_asthma_exacerbations => 'Exacerbations d\'asthme';

  @override
  String get no2_risk_allergen_response => 'Réponse aux allergènes';

  @override
  String get no2_risk_mucociliary => 'Diminution mucociliaire';

  @override
  String get no2_risk_development_decrement => 'Diminution du développement pulmonaire';

  @override
  String get co_method => 'Photométrie infrarouge';

  @override
  String get co_source_incomplete_combustion => 'Combustion incomplète dans les véhicules';

  @override
  String get co_source_biomass_burning => 'Brûlage de biomasse et déchets';

  @override
  String get co_source_poorly_vented_stoves => 'Poêles mal ventilés';

  @override
  String get co_source_wildfires => 'Feux de forêt';

  @override
  String get co_risk_exercise_capacity => 'Réduction de la capacité d\'exercice';

  @override
  String get o3_method => 'Spectrophotométrie UV';

  @override
  String get o3_source_photochemical_reaction => 'Réaction photochimique avec la lumière du soleil';

  @override
  String get o3_risk_reduced_resp_rate => 'Diminution de la fréquence respiratoire';

  @override
  String get o3_risk_alveolitis => 'Alvéolite neutrophilique';

  @override
  String get o3_risk_hyperreactivity => 'Hyperréactivité bronchique';

  @override
  String get o3_risk_alveolar_epithelium => 'Altération de l\'épithélium alvéolaire';

  @override
  String get o3_risk_epithelial_damage => 'Lésion des cellules épithéliales';

  @override
  String get o3_risk_bronchiolization => 'Bronchiolisation';

  @override
  String get o3_risk_decreased_cvf_vef1 => 'Diminution du CVF et du VEF1';

  @override
  String get risksTitle => 'Risques';

  @override
  String get respiratoryProblems => 'Problèmes respiratoires';

  @override
  String get respiratoryProblemsDesc => 'L\'exposition à court terme peut irriter les poumons et provoquer une toux ou des difficultés respiratoires.';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get vehicleEmissions => 'Émissions des véhicules';

  @override
  String get vehicleEmissionsDesc => 'Voitures, camions et bus.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get tabPollutants => 'Polluants';

  @override
  String get tabWeather => 'Météo';

  @override
  String get forecastTitle => 'Prévision';

  @override
  String optionSelected(Object option) {
    return '$option sélectionné';
  }

  @override
  String errorLoadingTheme(Object error) {
    return 'Erreur lors du chargement du thème : $error';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get notifFilterAll => 'Toutes';

  @override
  String get notifFilterAlerts => 'Alertes';

  @override
  String get notifFilterSystem => 'Système';

  @override
  String get notifFilterTips => 'Conseils';

  @override
  String get today => 'AUJOURD\'HUI';

  @override
  String get yesterday => 'HIER';

  @override
  String get notifAirQualityBadTitle => 'Qualité de l\'air : Mauvaise';

  @override
  String get notifAirQualityBadBody => 'Les niveaux de PM2.5 ont fortement augmenté dans la zone de San Pedro. Pensez à porter un masque et à limiter les activités en plein air.';

  @override
  String get notifRainForecastTitle => 'Prévision de pluie';

  @override
  String get notifRainForecastBody => 'Une pluie légère est attendue dans les prochaines heures, ce qui pourrait aider à nettoyer l\'air.';

  @override
  String get notifNewStationTitle => 'Nouvelle station ajoutée';

  @override
  String get notifNewStationBody => 'Nous surveillons désormais la qualité de l\'air à Santa Catarina.';

  @override
  String get notifHealthTipTitle => 'Recommandation de santé';

  @override
  String get notifHealthTipBody => 'Les niveaux de pollen sont élevés. Évitez les activités en plein air si vous êtes allergique.';

  @override
  String get versionLabel => 'Version 1.0.2';

  @override
  String get dataProviderCredit => 'Données fournies par SIMA N.L.';

  @override
  String get notificationsHeader => 'NOTIFICATIONS';

  @override
  String get criticalAlertsTitle => 'Alertes critiques';

  @override
  String get criticalAlertsSubtitle => 'Notifier lorsque la qualité de l\'air est dangereuse';

  @override
  String get alertsEnabled => 'Alertes critiques activées';

  @override
  String get alertsDisabled => 'Alertes critiques désactivées';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageDescription => 'Choisissez la langue de l\'interface de l\'application.';

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String get sortPlusQuality => 'Qualité élevée en premier';

  @override
  String get sortMinusQuality => 'Qualité faible en premier';

  @override
  String get sortAToZ => 'A → Z';

  @override
  String get sortZToA => 'Z → A';

  @override
  String get themeTitle => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get infoHeader => 'INFORMATIONS';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get visualizationHeader => 'VISUALISATION';

  @override
  String get filterAll => 'Toutes les stations';

  @override
  String get filterGood => 'Bonne';

  @override
  String get filterModerate => 'Acceptable';

  @override
  String get filterUnhealthy => 'Mauvaise';

  @override
  String get filterFavorites => 'Favoris';

  @override
  String get filterNearest => 'Les plus proches';

  @override
  String get airQualityGood => 'Bonne';

  @override
  String get airQualityAcceptable => 'Acceptable';

  @override
  String get airQualityBad => 'Mauvaise';

  @override
  String get airQualityVeryBad => 'Très mauvaise';

  @override
  String get airQualityExtremelyBad => 'Extrêmement mauvaise';

  @override
  String get airQualityUnknown => 'Inconnue';
}
