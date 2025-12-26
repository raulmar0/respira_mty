// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Respira MTY';

  @override
  String get stationsMapTitle => '측정소 지도';

  @override
  String get stationsTitle => '측정소';

  @override
  String get errorLoadingAirQuality => '대기 질을 불러올 수 없습니다. 연결을 확인하세요.';

  @override
  String get searchHint => '측정소 검색…';

  @override
  String lastUpdatedPrefix(Object time) {
    return '최종 업데이트: $time';
  }

  @override
  String get lastUpdatedUnknown => '최종 업데이트: —';

  @override
  String get noFavorites => '선택된 즐겨찾기가 없습니다';

  @override
  String get favoriteHint => '여기에 표시하려면 측정소에서 하트를 탭하세요.';

  @override
  String get updatingStations => '측정소 업데이트 중...';

  @override
  String stationsUpdated(Object count) {
    return '측정소가 업데이트되었습니다: $count';
  }

  @override
  String updatingError(Object error) {
    return '측정소 업데이트 오류: $error';
  }

  @override
  String get updateStationsTooltip => '측정소 업데이트';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get temperatureNow => '현재 온도';

  @override
  String get partlyCloudy => '부분적으로 흐림';

  @override
  String get pm10 => '미세먼지 PM10';

  @override
  String get pm2_5 => '미세먼지 PM2.5';

  @override
  String get no2 => '이산화질소';

  @override
  String get so2 => '이산화황';

  @override
  String get co => '일산화탄소';

  @override
  String get o3 => '오존';

  @override
  String pollutantDetail(Object label) {
    return '상세: $label';
  }

  @override
  String get pollutantDetailTitle => '세부';

  @override
  String get measurementMethod => '측정 방법';

  @override
  String get shortTerm => '단기간';

  @override
  String get longTerm => '장기간';

  @override
  String get dataUnavailable => '데이터 없음';

  @override
  String get pm25_desc => '지름이 2.5 마이크로미터 이하인 미세 흡입성 입자입니다.';

  @override
  String get pm10_desc => '지름이 10 마이크로미터 이하인 흡입성 입자입니다.';

  @override
  String get o3_desc => '대류권 오존으로 호흡기 자극을 일으키며 호흡 문제를 악화시킬 수 있습니다.';

  @override
  String get no2_desc => '이산화질소는 자극을 일으키고 호흡기 질환을 악화시킬 수 있습니다.';

  @override
  String get so2_desc => '이산화황은 기도를 자극하고 천식을 악화시킬 수 있습니다.';

  @override
  String get co_desc => '일산화탄소는 혈액의 산소 운반 능력을 감소시킵니다.';

  @override
  String get genericPollutantInfo => '이 오염물질에 대한 정보입니다.';

  @override
  String get pm10_method => '베타 감쇠 및 백색광 산란';

  @override
  String get pm10_source_resuspended => '재부유된 도로먼지';

  @override
  String get pm10_source_construction => '건설 활동';

  @override
  String get pm10_source_mining => '채석 및 채굴';

  @override
  String get pm10_source_fuel_burning => '연료 연소';

  @override
  String get pm10_source_erosion => '토양 침식';

  @override
  String get pm10_risk_morbidity => '호흡기 이환율 및 사망률 증가';

  @override
  String get pm10_risk_function => '폐 기능 감소';

  @override
  String get pm10_risk_defense => '폐 방어 기전의 간섭';

  @override
  String get pm10_risk_bronchial => '기관지 폐쇄 증후군';

  @override
  String get pm10_risk_development => '호흡기 발달 장애';

  @override
  String get pm10_risk_cancer => '암 위험 증가 (PAH)';

  @override
  String get pm25_method => '베타 감쇠 및 백색광 산란';

  @override
  String get pm25_source_vehicle_combustion => '차량 연소 (디젤)';

  @override
  String get pm25_source_industry => '산업 공정';

  @override
  String get pm25_source_agricultural_burn => '농업 소각';

  @override
  String get pm25_source_wildfires => '산불';

  @override
  String get pm25_risk_morbidity => '호흡기 이환율 및 사망률 증가';

  @override
  String get pm25_risk_function => '폐 기능 감소';

  @override
  String get pm25_risk_defense => '폐 방어 기전의 간섭';

  @override
  String get pm25_risk_bronchial => '기관지 폐쇄 증후군';

  @override
  String get pm25_risk_development => '호흡기 발달 장애';

  @override
  String get pm25_risk_cancer => '암 위험 증가 (PAH)';

  @override
  String get so2_method => '펄스 UV 형광법';

  @override
  String get so2_source_refineries => '정유 공장';

  @override
  String get so2_source_power_plants => '발전소';

  @override
  String get so2_source_boilers => '산업 보일러';

  @override
  String get so2_source_metal_smelting => '제련';

  @override
  String get so2_source_volcanoes => '화산';

  @override
  String get so2_risk_obstruction => '기관지 폐색';

  @override
  String get so2_risk_hypersecretion => '기관지 과다분비';

  @override
  String get so2_risk_chronic_bronchitis => '만성 기관지염';

  @override
  String get no2_method => '기상 상태에서의 화학발광';

  @override
  String get no2_source_vehicles => '자동차';

  @override
  String get no2_source_power_plants => '발전소';

  @override
  String get no2_source_industrial_ovens => '산업용 가마';

  @override
  String get no2_risk_hyperreactivity => '기관지 과민성 증가';

  @override
  String get no2_risk_asthma_exacerbations => '천식 악화';

  @override
  String get no2_risk_allergen_response => '알레르기 반응';

  @override
  String get no2_risk_mucociliary => '섬모 기능 저하';

  @override
  String get no2_risk_development_decrement => '폐 발달 저하';

  @override
  String get co_method => '적외선 광도계';

  @override
  String get co_source_incomplete_combustion => '차량의 불완전 연소';

  @override
  String get co_source_biomass_burning => '바이오매스 및 쓰레기 연소';

  @override
  String get co_source_poorly_vented_stoves => '통풍이 잘 안 되는 난로';

  @override
  String get co_source_wildfires => '산불';

  @override
  String get co_risk_exercise_capacity => '운동 능력 감소';

  @override
  String get o3_method => '자외선 분광법';

  @override
  String get o3_source_photochemical_reaction => '일광과의 광화학 반응';

  @override
  String get o3_risk_reduced_resp_rate => '호흡수 감소';

  @override
  String get o3_risk_alveolitis => '호중구성 폐포염';

  @override
  String get o3_risk_hyperreactivity => '기관지 과민성';

  @override
  String get o3_risk_alveolar_epithelium => '폐포 상피 변화';

  @override
  String get o3_risk_epithelial_damage => '상피 세포 손상';

  @override
  String get o3_risk_bronchiolization => '세기관지화';

  @override
  String get o3_risk_decreased_cvf_vef1 => 'CVF 및 VEF1 감소';

  @override
  String get risksTitle => '위험';

  @override
  String get respiratoryProblems => '호흡기 문제';

  @override
  String get respiratoryProblemsDesc => '단기간 노출은 폐를 자극하고 기침이나 호흡 곤란을 일으킬 수 있습니다.';

  @override
  String get sourcesTitle => '출처';

  @override
  String get vehicleEmissions => '차량 배출';

  @override
  String get vehicleEmissionsDesc => '자동차, 트럭 및 버스.';

  @override
  String get settingsTitle => '설정';

  @override
  String get tabPollutants => '오염물질';

  @override
  String get tabWeather => '날씨';

  @override
  String get forecastTitle => '예보';

  @override
  String optionSelected(Object option) {
    return '$option 선택됨';
  }

  @override
  String errorLoadingTheme(Object error) {
    return '테마 로드 오류: $error';
  }

  @override
  String get notificationsTitle => '알림';

  @override
  String get markAllRead => '모두 읽음로 표시';

  @override
  String get notifFilterAll => '모두';

  @override
  String get notifFilterAlerts => '알림';

  @override
  String get notifFilterSystem => '시스템';

  @override
  String get notifFilterTips => '팁';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get notifAirQualityBadTitle => '대기 상태: 나쁨';

  @override
  String get notifAirQualityBadBody => 'San Pedro 지역의 PM2.5 수치가 급상승했습니다. 마스크를 착용하고 야외 활동을 제한하십시오.';

  @override
  String get notifRainForecastTitle => '강우 예보';

  @override
  String get notifRainForecastBody => '향후 몇 시간 동안 약한 비가 예상되어 공기 정화에 도움이 될 수 있습니다.';

  @override
  String get notifNewStationTitle => '새 측정소 추가';

  @override
  String get notifNewStationBody => '이제 Santa Catarina 지역의 대기질을 모니터링합니다.';

  @override
  String get notifHealthTipTitle => '건강 권장사항';

  @override
  String get notifHealthTipBody => '꽃가루 수치가 높습니다. 알레르기가 있는 경우 야외 활동을 피하십시오.';

  @override
  String get versionLabel => '버전 1.0.2';

  @override
  String get dataProviderCredit => '데이터 제공: SIMA N.L.';

  @override
  String get notificationsHeader => '알림';

  @override
  String get criticalAlertsTitle => '중요 알림';

  @override
  String get criticalAlertsSubtitle => '공기 질이 위험할 때 알림';

  @override
  String get alertsEnabled => '중요 알림 켜짐';

  @override
  String get alertsDisabled => '중요 알림 꺼짐';

  @override
  String get languageTitle => '언어';

  @override
  String get languageDescription => '앱 인터페이스의 언어를 선택하세요.';

  @override
  String get saveChanges => '변경사항 저장';

  @override
  String get sortPlusQuality => '좋은 품질 우선';

  @override
  String get sortMinusQuality => '나쁜 품질 우선';

  @override
  String get sortAToZ => 'A → Z';

  @override
  String get sortZToA => 'Z → A';

  @override
  String get themeTitle => '테마';

  @override
  String get themeLight => '밝게';

  @override
  String get themeDark => '어둡게';

  @override
  String get themeSystem => '시스템';

  @override
  String get infoHeader => '정보';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get aboutApp => '앱 정보';

  @override
  String get visualizationHeader => '표시';

  @override
  String get filterAll => '모든 측정소';

  @override
  String get filterGood => '양호';

  @override
  String get filterModerate => '보통';

  @override
  String get filterUnhealthy => '나쁨';

  @override
  String get filterFavorites => '즐겨찾기';

  @override
  String get filterNearest => '가까운 측정소';

  @override
  String get airQualityGood => '좋음';

  @override
  String get airQualityAcceptable => '보통';

  @override
  String get airQualityBad => '나쁨';

  @override
  String get airQualityVeryBad => '매우 나쁨';

  @override
  String get airQualityExtremelyBad => '매우 심각';

  @override
  String get airQualityUnknown => '알 수 없음';
}
