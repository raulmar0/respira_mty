class RawStationData {
  final String? urlCode;
  final String? parameter;
  final dynamic hrAveData;
  final String? unit;
  final String? date;
  final String? name;
  final String? zone;

  const RawStationData({
    this.urlCode,
    this.parameter,
    this.hrAveData,
    this.unit,
    this.date,
    this.name,
    this.zone,
  });

  factory RawStationData.fromJson(Map<String, dynamic> json) {
    return RawStationData(
      urlCode: json['urlCode'] as String?,
      parameter: json['Parameter'] as String?,
      hrAveData: json['HrAveData'],
      unit: json['Unit'] as String?,
      date: json['Date'] as String?,
      name: json['name'] as String?,
      zone: json['zone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (urlCode != null) 'urlCode': urlCode,
      if (parameter != null) 'Parameter': parameter,
      if (hrAveData != null) 'HrAveData': hrAveData,
      if (unit != null) 'Unit': unit,
      if (date != null) 'Date': date,
      if (name != null) 'name': name,
      if (zone != null) 'zone': zone,
    };
  }

  RawStationData copyWith({
    String? urlCode,
    String? parameter,
    dynamic hrAveData,
    String? unit,
    String? date,
    String? name,
    String? zone,
  }) {
    return RawStationData(
      urlCode: urlCode ?? this.urlCode,
      parameter: parameter ?? this.parameter,
      hrAveData: hrAveData ?? this.hrAveData,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      name: name ?? this.name,
      zone: zone ?? this.zone,
    );
  }
}