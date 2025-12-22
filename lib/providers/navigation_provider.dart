import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para controlar el índice seleccionado del BottomNavigationBar
class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 1; // valor por defecto: Lista (index 1)

  void setIndex(int index) => state = index;
}

final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);
