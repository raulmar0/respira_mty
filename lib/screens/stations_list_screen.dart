import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/station_provider.dart';
import '../widgets/station_card.dart';
import '../widgets/sort_button.dart';


class StationsListScreen extends ConsumerStatefulWidget {
  const StationsListScreen({super.key});

  @override
  ConsumerState<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends ConsumerState<StationsListScreen> with AutomaticKeepAliveClientMixin<StationsListScreen> {
  bool _showSearch = false;
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true;

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final stationsAsync = ref.watch(filteredStationsProvider);
    final favorites = ref.watch(favoriteStationsProvider);
    final selectedFilter = ref.watch(stationsListFilterProvider);
    final query = ref.watch(stationSearchQueryProvider);
    final lastUpdate = ref.watch(lastUpdateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estaciones',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color ?? theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isRefreshing
                            ? SizedBox(
                                width: 36,
                                height: 36,
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color?>(theme.iconTheme.color ?? Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                tooltip: 'Actualizar estaciones',
                                icon: const Icon(Icons.refresh),
                                color: theme.iconTheme.color,
                                onPressed: () async {
                                  if (_isRefreshing) return;
                                  setState(() => _isRefreshing = true);
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Actualizando estaciones...')),
                                  );
                                  try {
                                    final updatedList = await ref.refresh(airQualityProvider.future);
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Estaciones actualizadas: ${updatedList.length}')),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Error al actualizar estaciones: $e')),
                                    );
                                    debugPrint('Error refreshing airQualityProvider: $e');
                                  } finally {
                                    if (mounted) setState(() => _isRefreshing = false);
                                  }
                                },
                              ),
                      ),
                      const SizedBox(width: 8),

                      // Sort button (custom design)
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: const SortButton(),
                      ),

                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color ?? theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _showSearch ? Icons.close : Icons.search,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSearch = !_showSearch;
                            });
                            if (!_showSearch) {
                              ref
                                  .read(stationSearchQueryProvider.notifier)
                                  .setQuery('');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_showSearch) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Buscar estación…',
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref
                                    .read(stationSearchQueryProvider.notifier)
                                    .setQuery('');
                              },
                            ),
                    ),
                    onChanged: (value) {
                      ref
                          .read(stationSearchQueryProvider.notifier)
                          .setQuery(value);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Center(
                child: Text(
                  lastUpdate != null
                      ? 'LAST UPDATED: ${_formatTime(lastUpdate)}'
                      : 'LAST UPDATED: —',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      'All Stations',
                      isSelected: selectedFilter == StationsListFilter.all,
                      onTap: () => ref
                          .read(stationsListFilterProvider.notifier)
                          .setFilter(StationsListFilter.all),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip(
                      'Favorites',
                      isSelected:
                          selectedFilter == StationsListFilter.favorites,
                      onTap: () => ref
                          .read(stationsListFilterProvider.notifier)
                          .setFilter(StationsListFilter.favorites),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip(
                      'Nearest',
                      isSelected: selectedFilter == StationsListFilter.nearest,
                      onTap: () => ref
                          .read(stationsListFilterProvider.notifier)
                          .setFilter(StationsListFilter.nearest),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: selectedFilter == StationsListFilter.favorites && favorites.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_border, size: 56, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay favoritos seleccionados',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Marca estaciones con el corazón para verlas aquí.',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : stationsAsync.when(
                        data: (stations) => ListView.builder(
                          itemCount: stations.length,
                          itemBuilder: (context, index) {
                            final station = stations[index];
                            final isFavorite = favorites.contains(station.id);
                            return StationCard(
                              station: station,
                              isFavorite: isFavorite,
                              onFavoriteToggle: () {
                                ref
                                    .read(favoriteStationsProvider.notifier)
                                    .toggle(station.id);
                              },
                            );
                          },
                        ),
                        loading: () => ListView.builder(
                          itemCount: 4,
                          padding: const EdgeInsets.only(top: 0, bottom: 16),
                          itemBuilder: (context, index) => const StationCardSkeleton(),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'No se pudieron cargar las estaciones',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? theme.colorScheme.primary.withOpacity(0.18) : const Color(0xFF1A1F36);
    final unselectedColor = theme.cardTheme.color ?? (isDark ? theme.colorScheme.surface : Colors.white);
    final selectedTextColor = isDark ? theme.colorScheme.primary : Colors.white;
    final unselectedTextColor = isDark ? Colors.grey[300] : Colors.grey[600];
    final selectedShadow = isDark
        ? theme.colorScheme.primary.withOpacity(0.18)
        : const Color(0xFF1A1F36).withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
