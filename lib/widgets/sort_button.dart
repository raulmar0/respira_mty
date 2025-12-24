import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/station_provider.dart';
import '../utils/app_colors.dart';

/// Sort button used in the stations list header.
/// Visual design adapted from the provided request, but integrated with app theme
/// and Riverpod provider so selection persists in memory.
class SortButton extends ConsumerStatefulWidget {
  const SortButton({super.key});

  @override
  ConsumerState<SortButton> createState() => _SortButtonState();
}

enum SortOption { plusQuality, minusQuality, aToZ, zToA }

class _SortButtonState extends ConsumerState<SortButton> {
  SortOption _selectedOption = SortOption.plusQuality;

  // Tailwind-inspired palette (kept as requested)
  final Color primaryColor = const Color(0xFF141C35);
  final Color accentGreen = const Color(0xFF00C853);
  final Color surfaceDark = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Keep local selection in sync with provider (reads current every build)
    final current = ref.watch(stationsSortProvider);
    _selectedOption = _mapStationsSortToOption(current);

    // Trigger style: neutral by default, highlighted when menu is open
    final neutralBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final neutralIcon = theme.iconTheme.color ?? Colors.black;

    // Use PopupMenuButton for easier menu handling
    return PopupMenuButton<SortOption>(
      onSelected: (SortOption selected) {
        setState(() {
          _selectedOption = selected;
        });
        final target = _mapOptionToStationsSort(selected);
        ref.read(stationsSortProvider.notifier).set(target);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_labelForOption(selected)} seleccionado')),
        );
      },
      itemBuilder: (BuildContext context) => [
        _buildMenuItem(SortOption.plusQuality, "+ Calidad", theme),
        _buildMenuItem(SortOption.minusQuality, "- Calidad", theme),
        _buildMenuItem(SortOption.aToZ, "A → Z", theme),
        _buildMenuItem(SortOption.zToA, "Z → A", theme),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: neutralBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.sort, color: neutralIcon),
      ),
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(SortOption option, String text, ThemeData theme) {
    final bool isSelected = _selectedOption == option;
    final isDark = theme.brightness == Brightness.dark;

    // Maintenance colors (light/dark adapted)
    final maintenanceBgLight = AppColors.statusFueraServicioBackground; // light bg
    final maintenanceTextLight = AppColors.statusFueraServicioText; // dark text on light bg
    final maintenanceBgDark = AppColors.statusFueraServicioCircle.withValues(alpha: 0.12); // subtle dark bg in dark mode

    final selectedBg = isSelected ? (isDark ? maintenanceBgDark : maintenanceBgLight) : Colors.transparent;
    final selectedTextColor = isSelected ? (isDark ? Colors.white : maintenanceTextLight) : (isDark ? Colors.white70 : Colors.black87);
    final checkColor = isDark ? Colors.white : maintenanceTextLight;

    return PopupMenuItem<SortOption>(
      value: option,
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selectedBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selectedTextColor,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: checkColor, size: 18),
          ],
        ),
      ),
    );
  }

  String _labelForOption(SortOption option) {
    switch (option) {
      case SortOption.plusQuality:
        return '+ Calidad';
      case SortOption.minusQuality:
        return '- Calidad';
      case SortOption.aToZ:
        return 'A → Z';
      case SortOption.zToA:
        return 'Z → A';
    }
  }

  StationsSort _mapOptionToStationsSort(SortOption option) {
    switch (option) {
      case SortOption.plusQuality:
        return StationsSort.plusQuality;
      case SortOption.minusQuality:
        return StationsSort.minusQuality;
      case SortOption.aToZ:
        return StationsSort.az;
      case SortOption.zToA:
        return StationsSort.za;
    }
  }

  SortOption _mapStationsSortToOption(StationsSort sort) {
    switch (sort) {
      case StationsSort.plusQuality:
        return SortOption.plusQuality;
      case StationsSort.minusQuality:
        return SortOption.minusQuality;
      case StationsSort.az:
        return SortOption.aToZ;
      case StationsSort.za:
        return SortOption.zToA;
    }
  }
}
