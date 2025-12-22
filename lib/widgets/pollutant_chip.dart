import 'package:flutter/material.dart';

class PollutantChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String unit;
  final double? width;
  final bool compact;

  const PollutantChip({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.unit = 'µg/m³',
    this.width,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? (compact ? 44.0 : 50.0);
    final labelSize = compact ? 9.0 : 10.0;
    final valueSize = compact ? 12.0 : 14.0;
    final unitSize = compact ? 9.0 : 10.0;

    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
          SizedBox(height: compact ? 0 : 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: unitSize,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
