import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Respira MTY'**
  String get appTitle;

  /// No description provided for @stationsMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Stations Map'**
  String get stationsMapTitle;

  /// No description provided for @stationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stationsTitle;

  /// No description provided for @errorLoadingAirQuality.
  ///
  /// In en, this message translates to:
  /// **'Could not load air quality. Check your connection.'**
  String get errorLoadingAirQuality;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search station…'**
  String get searchHint;

  /// No description provided for @lastUpdatedPrefix.
  ///
  /// In en, this message translates to:
  /// **'LAST UPDATED: {time}'**
  String lastUpdatedPrefix(Object time);

  /// No description provided for @lastUpdatedUnknown.
  ///
  /// In en, this message translates to:
  /// **'LAST UPDATED: —'**
  String get lastUpdatedUnknown;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites selected'**
  String get noFavorites;

  /// No description provided for @favoriteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on stations to see them here.'**
  String get favoriteHint;

  /// No description provided for @updatingStations.
  ///
  /// In en, this message translates to:
  /// **'Updating stations...'**
  String get updatingStations;

  /// No description provided for @stationsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stations updated: {count}'**
  String stationsUpdated(Object count);

  /// No description provided for @updatingError.
  ///
  /// In en, this message translates to:
  /// **'Error updating stations: {error}'**
  String updatingError(Object error);

  /// No description provided for @updateStationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update stations'**
  String get updateStationsTooltip;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @temperatureNow.
  ///
  /// In en, this message translates to:
  /// **'Current Temperature'**
  String get temperatureNow;

  /// No description provided for @partlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get partlyCloudy;

  /// No description provided for @pm10.
  ///
  /// In en, this message translates to:
  /// **'Particulate Matter PM10'**
  String get pm10;

  /// No description provided for @pm2_5.
  ///
  /// In en, this message translates to:
  /// **'Particulate Matter PM2.5'**
  String get pm2_5;

  /// No description provided for @no2.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Dioxide'**
  String get no2;

  /// No description provided for @so2.
  ///
  /// In en, this message translates to:
  /// **'Sulfur Dioxide'**
  String get so2;

  /// No description provided for @co.
  ///
  /// In en, this message translates to:
  /// **'Carbon Monoxide'**
  String get co;

  /// No description provided for @o3.
  ///
  /// In en, this message translates to:
  /// **'Ozone'**
  String get o3;

  /// No description provided for @pollutantDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail: {label}'**
  String pollutantDetail(Object label);

  /// No description provided for @pollutantDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get pollutantDetailTitle;

  /// No description provided for @measurementMethod.
  ///
  /// In en, this message translates to:
  /// **'Measurement Method'**
  String get measurementMethod;

  /// No description provided for @shortTerm.
  ///
  /// In en, this message translates to:
  /// **'Short-term'**
  String get shortTerm;

  /// No description provided for @longTerm.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get longTerm;

  /// No description provided for @dataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data unavailable'**
  String get dataUnavailable;

  /// No description provided for @pm25_desc.
  ///
  /// In en, this message translates to:
  /// **'Fine inhalable particles with aerodynamic diameters of 2.5 micrometers or less.'**
  String get pm25_desc;

  /// No description provided for @pm10_desc.
  ///
  /// In en, this message translates to:
  /// **'Inhalable particles with diameters of 10 micrometers or less.'**
  String get pm10_desc;

  /// No description provided for @o3_desc.
  ///
  /// In en, this message translates to:
  /// **'Tropospheric ozone, a respiratory irritant that can worsen breathing problems.'**
  String get o3_desc;

  /// No description provided for @no2_desc.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen dioxide, can cause irritation and worsen respiratory illnesses.'**
  String get no2_desc;

  /// No description provided for @so2_desc.
  ///
  /// In en, this message translates to:
  /// **'Sulfur dioxide, can irritate airways and aggravate asthma.'**
  String get so2_desc;

  /// No description provided for @co_desc.
  ///
  /// In en, this message translates to:
  /// **'Carbon monoxide, reduces the blood\'s ability to carry oxygen.'**
  String get co_desc;

  /// No description provided for @genericPollutantInfo.
  ///
  /// In en, this message translates to:
  /// **'Information about this pollutant.'**
  String get genericPollutantInfo;

  /// No description provided for @pm10_method.
  ///
  /// In en, this message translates to:
  /// **'Beta attenuation and white light scattering'**
  String get pm10_method;

  /// No description provided for @pm10_source_resuspended.
  ///
  /// In en, this message translates to:
  /// **'Resuspended road dust'**
  String get pm10_source_resuspended;

  /// No description provided for @pm10_source_construction.
  ///
  /// In en, this message translates to:
  /// **'Construction activities'**
  String get pm10_source_construction;

  /// No description provided for @pm10_source_mining.
  ///
  /// In en, this message translates to:
  /// **'Mining and quarrying'**
  String get pm10_source_mining;

  /// No description provided for @pm10_source_fuel_burning.
  ///
  /// In en, this message translates to:
  /// **'Fuel burning'**
  String get pm10_source_fuel_burning;

  /// No description provided for @pm10_source_erosion.
  ///
  /// In en, this message translates to:
  /// **'Soil erosion'**
  String get pm10_source_erosion;

  /// No description provided for @pm10_risk_morbidity.
  ///
  /// In en, this message translates to:
  /// **'Increased respiratory morbidity and mortality'**
  String get pm10_risk_morbidity;

  /// No description provided for @pm10_risk_function.
  ///
  /// In en, this message translates to:
  /// **'Reduced lung function'**
  String get pm10_risk_function;

  /// No description provided for @pm10_risk_defense.
  ///
  /// In en, this message translates to:
  /// **'Interference with pulmonary defense mechanisms'**
  String get pm10_risk_defense;

  /// No description provided for @pm10_risk_bronchial.
  ///
  /// In en, this message translates to:
  /// **'Bronchial obstructive syndrome'**
  String get pm10_risk_bronchial;

  /// No description provided for @pm10_risk_development.
  ///
  /// In en, this message translates to:
  /// **'Impaired respiratory system development'**
  String get pm10_risk_development;

  /// No description provided for @pm10_risk_cancer.
  ///
  /// In en, this message translates to:
  /// **'Increased risk of cancer (PAHs)'**
  String get pm10_risk_cancer;

  /// No description provided for @pm25_method.
  ///
  /// In en, this message translates to:
  /// **'Beta attenuation and white light scattering'**
  String get pm25_method;

  /// No description provided for @pm25_source_vehicle_combustion.
  ///
  /// In en, this message translates to:
  /// **'Vehicle combustion (diesel)'**
  String get pm25_source_vehicle_combustion;

  /// No description provided for @pm25_source_industry.
  ///
  /// In en, this message translates to:
  /// **'Industrial processes'**
  String get pm25_source_industry;

  /// No description provided for @pm25_source_agricultural_burn.
  ///
  /// In en, this message translates to:
  /// **'Agricultural burning'**
  String get pm25_source_agricultural_burn;

  /// No description provided for @pm25_source_wildfires.
  ///
  /// In en, this message translates to:
  /// **'Wildfires'**
  String get pm25_source_wildfires;

  /// No description provided for @pm25_risk_morbidity.
  ///
  /// In en, this message translates to:
  /// **'Increased respiratory morbidity and mortality'**
  String get pm25_risk_morbidity;

  /// No description provided for @pm25_risk_function.
  ///
  /// In en, this message translates to:
  /// **'Reduced lung function'**
  String get pm25_risk_function;

  /// No description provided for @pm25_risk_defense.
  ///
  /// In en, this message translates to:
  /// **'Interference with pulmonary defense mechanisms'**
  String get pm25_risk_defense;

  /// No description provided for @pm25_risk_bronchial.
  ///
  /// In en, this message translates to:
  /// **'Bronchial obstructive syndrome'**
  String get pm25_risk_bronchial;

  /// No description provided for @pm25_risk_development.
  ///
  /// In en, this message translates to:
  /// **'Impaired respiratory system development'**
  String get pm25_risk_development;

  /// No description provided for @pm25_risk_cancer.
  ///
  /// In en, this message translates to:
  /// **'Increased risk of cancer (PAHs)'**
  String get pm25_risk_cancer;

  /// No description provided for @so2_method.
  ///
  /// In en, this message translates to:
  /// **'Pulsed UV fluorescence'**
  String get so2_method;

  /// No description provided for @so2_source_refineries.
  ///
  /// In en, this message translates to:
  /// **'Oil refineries'**
  String get so2_source_refineries;

  /// No description provided for @so2_source_power_plants.
  ///
  /// In en, this message translates to:
  /// **'Power plants'**
  String get so2_source_power_plants;

  /// No description provided for @so2_source_boilers.
  ///
  /// In en, this message translates to:
  /// **'Industrial boilers'**
  String get so2_source_boilers;

  /// No description provided for @so2_source_metal_smelting.
  ///
  /// In en, this message translates to:
  /// **'Metal smelting'**
  String get so2_source_metal_smelting;

  /// No description provided for @so2_source_volcanoes.
  ///
  /// In en, this message translates to:
  /// **'Volcanoes'**
  String get so2_source_volcanoes;

  /// No description provided for @so2_risk_obstruction.
  ///
  /// In en, this message translates to:
  /// **'Bronchial obstruction'**
  String get so2_risk_obstruction;

  /// No description provided for @so2_risk_hypersecretion.
  ///
  /// In en, this message translates to:
  /// **'Bronchial hypersecretion'**
  String get so2_risk_hypersecretion;

  /// No description provided for @so2_risk_chronic_bronchitis.
  ///
  /// In en, this message translates to:
  /// **'Chronic bronchitis'**
  String get so2_risk_chronic_bronchitis;

  /// No description provided for @no2_method.
  ///
  /// In en, this message translates to:
  /// **'Gas-phase chemiluminescence'**
  String get no2_method;

  /// No description provided for @no2_source_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Motor vehicles'**
  String get no2_source_vehicles;

  /// No description provided for @no2_source_power_plants.
  ///
  /// In en, this message translates to:
  /// **'Power generation plants'**
  String get no2_source_power_plants;

  /// No description provided for @no2_source_industrial_ovens.
  ///
  /// In en, this message translates to:
  /// **'Industrial furnaces'**
  String get no2_source_industrial_ovens;

  /// No description provided for @no2_risk_hyperreactivity.
  ///
  /// In en, this message translates to:
  /// **'Bronchial hyperreactivity'**
  String get no2_risk_hyperreactivity;

  /// No description provided for @no2_risk_asthma_exacerbations.
  ///
  /// In en, this message translates to:
  /// **'Asthma exacerbations'**
  String get no2_risk_asthma_exacerbations;

  /// No description provided for @no2_risk_allergen_response.
  ///
  /// In en, this message translates to:
  /// **'Allergen response'**
  String get no2_risk_allergen_response;

  /// No description provided for @no2_risk_mucociliary.
  ///
  /// In en, this message translates to:
  /// **'Mucociliary decrement'**
  String get no2_risk_mucociliary;

  /// No description provided for @no2_risk_development_decrement.
  ///
  /// In en, this message translates to:
  /// **'Decreased developmental lung function'**
  String get no2_risk_development_decrement;

  /// No description provided for @co_method.
  ///
  /// In en, this message translates to:
  /// **'Infrared photometry'**
  String get co_method;

  /// No description provided for @co_source_incomplete_combustion.
  ///
  /// In en, this message translates to:
  /// **'Incomplete combustion in vehicles'**
  String get co_source_incomplete_combustion;

  /// No description provided for @co_source_biomass_burning.
  ///
  /// In en, this message translates to:
  /// **'Biomass and waste burning'**
  String get co_source_biomass_burning;

  /// No description provided for @co_source_poorly_vented_stoves.
  ///
  /// In en, this message translates to:
  /// **'Poorly ventilated stoves'**
  String get co_source_poorly_vented_stoves;

  /// No description provided for @co_source_wildfires.
  ///
  /// In en, this message translates to:
  /// **'Wildfires'**
  String get co_source_wildfires;

  /// No description provided for @co_risk_exercise_capacity.
  ///
  /// In en, this message translates to:
  /// **'Reduced exercise capacity'**
  String get co_risk_exercise_capacity;

  /// No description provided for @o3_method.
  ///
  /// In en, this message translates to:
  /// **'UV spectrophotometry'**
  String get o3_method;

  /// No description provided for @o3_source_photochemical_reaction.
  ///
  /// In en, this message translates to:
  /// **'Photochemical reaction with sunlight'**
  String get o3_source_photochemical_reaction;

  /// No description provided for @o3_risk_reduced_resp_rate.
  ///
  /// In en, this message translates to:
  /// **'Decreased respiratory rate'**
  String get o3_risk_reduced_resp_rate;

  /// No description provided for @o3_risk_alveolitis.
  ///
  /// In en, this message translates to:
  /// **'Neutrophilic alveolitis'**
  String get o3_risk_alveolitis;

  /// No description provided for @o3_risk_hyperreactivity.
  ///
  /// In en, this message translates to:
  /// **'Bronchial hyperreactivity'**
  String get o3_risk_hyperreactivity;

  /// No description provided for @o3_risk_alveolar_epithelium.
  ///
  /// In en, this message translates to:
  /// **'Alteration of alveolar epithelium'**
  String get o3_risk_alveolar_epithelium;

  /// No description provided for @o3_risk_epithelial_damage.
  ///
  /// In en, this message translates to:
  /// **'Epithelial cell damage'**
  String get o3_risk_epithelial_damage;

  /// No description provided for @o3_risk_bronchiolization.
  ///
  /// In en, this message translates to:
  /// **'Bronchiolization'**
  String get o3_risk_bronchiolization;

  /// No description provided for @o3_risk_decreased_cvf_vef1.
  ///
  /// In en, this message translates to:
  /// **'Decreased CVF and VEF1'**
  String get o3_risk_decreased_cvf_vef1;

  /// No description provided for @risksTitle.
  ///
  /// In en, this message translates to:
  /// **'Risks'**
  String get risksTitle;

  /// No description provided for @respiratoryProblems.
  ///
  /// In en, this message translates to:
  /// **'Respiratory problems'**
  String get respiratoryProblems;

  /// No description provided for @respiratoryProblemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Short-term exposure can irritate the lungs and cause coughing or difficulty breathing.'**
  String get respiratoryProblemsDesc;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @vehicleEmissions.
  ///
  /// In en, this message translates to:
  /// **'Vehicle emissions'**
  String get vehicleEmissions;

  /// No description provided for @vehicleEmissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Cars, trucks and buses.'**
  String get vehicleEmissionsDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @tabPollutants.
  ///
  /// In en, this message translates to:
  /// **'Pollutants'**
  String get tabPollutants;

  /// No description provided for @tabWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get tabWeather;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecastTitle;

  /// No description provided for @optionSelected.
  ///
  /// In en, this message translates to:
  /// **'{option} selected'**
  String optionSelected(Object option);

  /// No description provided for @errorLoadingTheme.
  ///
  /// In en, this message translates to:
  /// **'Error loading theme: {error}'**
  String errorLoadingTheme(Object error);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @notifFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifFilterAll;

  /// No description provided for @notifFilterAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notifFilterAlerts;

  /// No description provided for @notifFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notifFilterSystem;

  /// No description provided for @notifFilterTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get notifFilterTips;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterday;

  /// No description provided for @notifAirQualityBadTitle.
  ///
  /// In en, this message translates to:
  /// **'Air quality: Poor'**
  String get notifAirQualityBadTitle;

  /// No description provided for @notifAirQualityBadBody.
  ///
  /// In en, this message translates to:
  /// **'PM2.5 levels have risen sharply in the San Pedro area. Consider using masks and limiting outdoor activity.'**
  String get notifAirQualityBadBody;

  /// No description provided for @notifRainForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain forecast'**
  String get notifRainForecastTitle;

  /// No description provided for @notifRainForecastBody.
  ///
  /// In en, this message translates to:
  /// **'Light rain is expected in the coming hours which could help clear the air.'**
  String get notifRainForecastBody;

  /// No description provided for @notifNewStationTitle.
  ///
  /// In en, this message translates to:
  /// **'New station added'**
  String get notifNewStationTitle;

  /// No description provided for @notifNewStationBody.
  ///
  /// In en, this message translates to:
  /// **'We now monitor air quality in Santa Catarina.'**
  String get notifNewStationBody;

  /// No description provided for @notifHealthTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Health recommendation'**
  String get notifHealthTipTitle;

  /// No description provided for @notifHealthTipBody.
  ///
  /// In en, this message translates to:
  /// **'Pollen levels are high. Avoid outdoor activities if you are allergic.'**
  String get notifHealthTipBody;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.2'**
  String get versionLabel;

  /// No description provided for @dataProviderCredit.
  ///
  /// In en, this message translates to:
  /// **'Data provided by SIMA N.L.'**
  String get dataProviderCredit;

  /// No description provided for @notificationsHeader.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsHeader;

  /// No description provided for @criticalAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get criticalAlertsTitle;

  /// No description provided for @criticalAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify when air quality is dangerous'**
  String get criticalAlertsSubtitle;

  /// No description provided for @alertsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts enabled'**
  String get alertsEnabled;

  /// No description provided for @alertsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts disabled'**
  String get alertsDisabled;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app interface.'**
  String get languageDescription;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @sortPlusQuality.
  ///
  /// In en, this message translates to:
  /// **'High quality first'**
  String get sortPlusQuality;

  /// No description provided for @sortMinusQuality.
  ///
  /// In en, this message translates to:
  /// **'Low quality first'**
  String get sortMinusQuality;

  /// No description provided for @sortAToZ.
  ///
  /// In en, this message translates to:
  /// **'A → Z'**
  String get sortAToZ;

  /// No description provided for @sortZToA.
  ///
  /// In en, this message translates to:
  /// **'Z → A'**
  String get sortZToA;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @infoHeader.
  ///
  /// In en, this message translates to:
  /// **'INFORMATION'**
  String get infoHeader;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @visualizationHeader.
  ///
  /// In en, this message translates to:
  /// **'VISUALIZATION'**
  String get visualizationHeader;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Stations'**
  String get filterAll;

  /// No description provided for @filterGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get filterGood;

  /// No description provided for @filterModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get filterModerate;

  /// No description provided for @filterUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get filterUnhealthy;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// No description provided for @filterNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get filterNearest;

  /// No description provided for @airQualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get airQualityGood;

  /// No description provided for @airQualityAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get airQualityAcceptable;

  /// No description provided for @airQualityBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get airQualityBad;

  /// No description provided for @airQualityVeryBad.
  ///
  /// In en, this message translates to:
  /// **'Very bad'**
  String get airQualityVeryBad;

  /// No description provided for @airQualityExtremelyBad.
  ///
  /// In en, this message translates to:
  /// **'Extremely bad'**
  String get airQualityExtremelyBad;

  /// No description provided for @airQualityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get airQualityUnknown;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
