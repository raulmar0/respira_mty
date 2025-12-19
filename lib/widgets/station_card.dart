import 'package:flutter/material.dart';
import '../models/station.dart';
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

  Color _getStatusColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF4CAF50); // Green
    if (aqi <= 100) return const Color(0xFFFFC107); // Yellow/Amber
    if (aqi <= 150) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  Color _getBackgroundColor(int aqi) {
    if (aqi <= 50) return const Color(0xFFE8F5E9); // Light Green
    if (aqi <= 100) return const Color(0xFFFFF8E1); // Light Yellow
    if (aqi <= 150) return const Color(0xFFFFF3E0); // Light Orange
    return const Color(0xFFFFEBEE); // Light Red
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(station.aqi);
    final badgeColor = _getBackgroundColor(station.aqi);
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
                      '${station.aqi} AQI',
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
                value: station.pm25.toStringAsFixed(1),
              ),
              PollutantChip(
                label: 'PM10',
                value: station.pm10.toStringAsFixed(1),
                valueColor: station.pm10 > 100 ? Colors.orange : null,
              ),
              PollutantChip(
                label: 'O3',
                value: station.o3.toStringAsFixed(0),
                unit: 'ppb',
              ),
              PollutantChip(
                label: 'NO2',
                value: station.no2.toStringAsFixed(0),
                unit: 'ppb',
              ),
              PollutantChip(
                label: 'SO2',
                value: station.so2.toStringAsFixed(0),
                unit: 'ppb',
              ),
              PollutantChip(
                label: 'CO',
                value: station.co.toStringAsFixed(2),
                unit: 'ppm',
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
