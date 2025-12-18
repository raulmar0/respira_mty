import 'package:flutter/material.dart';
import '../models/station.dart';
import 'pollutant_chip.dart';

class StationCard extends StatelessWidget {
  final Station station;

  const StationCard({super.key, required this.station});

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
              Row(
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (station.isFavorite) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              PollutantChip(label: 'PM2.5', value: station.pm25.toStringAsFixed(1)),
              PollutantChip(
                label: 'PM10',
                value: station.pm10.toStringAsFixed(1),
                valueColor: station.pm10 > 100 ? Colors.orange : null,
              ),
              PollutantChip(label: 'O3', value: station.o3.toStringAsFixed(0), unit: 'ppb'),
              PollutantChip(label: 'NO2', value: station.no2.toStringAsFixed(0), unit: 'ppb'),
              PollutantChip(label: 'SO2', value: station.so2.toStringAsFixed(0), unit: 'ppb'),
              PollutantChip(label: 'CO', value: station.co.toStringAsFixed(2), unit: 'ppm'),
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
