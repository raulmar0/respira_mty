import 'package:flutter/material.dart';
import '../models/station.dart';
import '../utils/air_quality_scale.dart';
import 'pollutant_chip.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const StationCard({
    super.key,
    required this.station,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dominant = station.dominantPollutant;
    final statusColor = dominant.color;
    final badgeColor = AirQualityScale.getBackgroundColorForCategory(dominant.category);
    final favorite = isFavorite ?? station.isFavorite;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onFavoriteToggle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: favorite ? const Color(0xFF4CAF50) : Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dominant.category == AirQualityCategory.maintenance
                          ? 'N/D'
                          : '${dominant.displayValue} ${dominant.name}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    station.status,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (station.updatedAt != null)
                Text(
                  _relativeTime(station.updatedAt!),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PollutantChip(
                label: 'PM2.5',
                value: station.pm25?.toStringAsFixed(1) ?? 'N/D',
                valueColor: station.pm25 != null ? AirQualityScale.getColorForCategory(AirQualityScale.getCategoryPM25(station.pm25!)) : Colors.grey,
              ),
              PollutantChip(
                label: 'PM10',
                value: station.pm10?.toStringAsFixed(1) ?? 'N/D',
                valueColor: station.pm10 != null ? AirQualityScale.getColorForCategory(AirQualityScale.getCategoryPM10(station.pm10!)) : Colors.grey,
              ),
              PollutantChip(
                label: 'O3',
                value: station.o3?.toStringAsFixed(0) ?? 'N/D',
                unit: 'ppb',
                valueColor: station.o3 != null ? AirQualityScale.getColorForCategory(AirQualityScale.getCategoryO3(station.o3!)) : Colors.grey,
              ),
              PollutantChip(
                label: 'NO2',
                value: station.no2?.toStringAsFixed(0) ?? 'N/D',
                unit: 'ppb',
                valueColor: station.no2 != null ? AirQualityScale.getColorForCategory(AirQualityScale.getCategoryNO2(station.no2!)) : Colors.grey,
              ),
              PollutantChip(
                label: 'SO2',
                value: station.so2?.toStringAsFixed(0) ?? 'N/D',
                unit: 'ppb',
                valueColor: station.so2 != null ? AirQualityScale.getColorForCategory(AirQualityScale.getCategorySO2(station.so2!)) : Colors.grey,
              ),
              PollutantChip(
                label: 'CO',
                value: station.co?.toStringAsFixed(2) ?? 'N/D',
                unit: 'ppm',
                valueColor: station.co != null ? AirQualityScale.getColorForCategory(AirQualityScale.getCategoryCO(station.co!)) : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime updatedAt) {
    final delta = DateTime.now().difference(updatedAt);
    if (delta.inMinutes < 1) return 'Updated just now';
    if (delta.inMinutes < 60) return 'Updated ${delta.inMinutes}m ago';
    if (delta.inHours < 24) return 'Updated ${delta.inHours}h ago';
    return 'Updated ${delta.inDays}d ago';
  }
}

class StationCardSkeleton extends StatelessWidget {
  const StationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.grey[200]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 18,
                  color: bg,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 24,
                color: bg,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 12, width: 120, color: bg),
          const SizedBox(height: 18),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Container(
                  height: 36,
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
