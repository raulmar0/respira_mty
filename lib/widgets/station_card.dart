import 'package:flutter/material.dart';
import '../models/station.dart';
import '../utils/air_quality_scale.dart';
import 'pollutant_chip.dart';
import '../screens/station_detail_screen.dart';

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
    final theme = Theme.of(context);
    final dominant = station.dominantPollutant;
    final statusTextColor = dominant.statusTextColor;
    final badgeColor = dominant.statusBackground;
    final circleColor = dominant.statusColors.circle;
    final favorite = isFavorite ?? station.isFavorite;
    final nameParts = station.name.split(',');
    final municipality = nameParts.first.trim();
    final zone = nameParts.length > 1
        ? nameParts.sublist(1).join(',').trim()
        : '';

    // Card background and shadow adapt to theme
    final cardColor =
        theme.cardTheme.color ??
        (theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white);
    final cardShadow = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.05);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
              builder: (c) => StationDetailScreenLight(station: station),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: municipality + favorite on the left, zone badge on the right (aligned vertically)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            municipality,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onFavoriteToggle,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: favorite
                                ? const Color(0xFF4CAF50)
                                : (theme.brightness == Brightness.dark
                                      ? Colors.grey[600]
                                      : Colors.grey),
                          ),
                        ),
                      ],
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
                      zone.isNotEmpty ? zone : municipality,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Second row: status dot and status text
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      station.status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = station.pollutantsFromUI.length;
                  final spacing = 8.0 * (count - 1);
                  final available = constraints.maxWidth - spacing;
                  final computedWidth = (available / count).clamp(40.0, 72.0);
                  final compact = computedWidth < 46.0;

                  final list = station.pollutantsFromUI;
                  final widgetList = List.generate(list.length, (i) {
                    final pollutant = list[i];
                    final isLast = i == list.length - 1;
                    final parameter = pollutant['parameter'] as String;
                    final value = pollutant['value'] as double?;
                    final displayLabel = _getDisplayLabel(parameter);
                    final unit =
                        pollutant['unit'] as String? ??
                        AirQualityScale.getUnitForParameter(parameter);
                    final color = value != null
                        ? AirQualityScale.getColorForParameter(parameter, value)
                        : Colors.grey;
                    final displayValue = value != null
                        ? (parameter.toUpperCase().contains('CO')
                              ? value.toStringAsFixed(2)
                              : value.toStringAsFixed(0))
                        : 'N/D';

                    return Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 8),
                      child: PollutantChip(
                        label: displayLabel,
                        value: displayValue,
                        unit: unit,
                        valueColor: color,
                        width: (computedWidth - 1.0).clamp(40.0, 72.0),
                        compact: compact,
                      ),
                    );
                  });

                  return Row(children: widgetList);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayLabel(String parameter) {
    switch (parameter.toUpperCase()) {
      case 'PM10M':
        return 'PM10';
      case 'PM25M':
        return 'PM2.5';
      case 'O3M':
        return 'O3';
      case 'NO2M':
        return 'NO2';
      case 'SO2M':
        return 'SO2';
      case 'COM':
        return 'CO';
      default:
        return parameter;
    }
  }
}

class StationCardSkeleton extends StatelessWidget {
  const StationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
    final cardColor =
        theme.cardTheme.color ??
        (theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white);
    final cardShadow = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.03);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
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
              Expanded(child: Container(height: 18, color: bg)),
              const SizedBox(width: 12),
              Container(width: 56, height: 24, color: bg),
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
