import '../utils/air_quality_scale.dart';

class AppNotification {
  final String id;
  final String stationId;
  final String stationName;
  final String pollutantName;
  final double pollutantValue;
  final String pollutantUnit;
  final AirQualityCategory category;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.pollutantName,
    required this.pollutantValue,
    required this.pollutantUnit,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      stationId: stationId,
      stationName: stationName,
      pollutantName: pollutantName,
      pollutantValue: pollutantValue,
      pollutantUnit: pollutantUnit,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stationId': stationId,
        'stationName': stationName,
        'pollutantName': pollutantName,
        'pollutantValue': pollutantValue,
        'pollutantUnit': pollutantUnit,
        'category': category.index,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      stationName: json['stationName'] as String,
      pollutantName: json['pollutantName'] as String,
      pollutantValue: (json['pollutantValue'] as num).toDouble(),
      pollutantUnit: json['pollutantUnit'] as String,
      category: AirQualityCategory.values[json['category'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
