import 'package:flutter/material.dart';

// Map a string name (from data) to an IconData. Add mappings as needed.
IconData iconFromName(String name) {
  switch (name) {
    case 'science':
      return Icons.science;
    case 'grain':
      return Icons.grain;
    case 'construction':
      return Icons.construction;
    case 'landscape':
      return Icons.landscape;
    case 'local_gas_station':
      return Icons.local_gas_station;
    case 'terrain':
      return Icons.terrain;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'air':
      return Icons.air;
    case 'shield':
      return Icons.shield;
    case 'block':
      return Icons.block;
    case 'child_care':
      return Icons.child_care;
    case 'warning':
      return Icons.warning;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'factory':
      return Icons.factory;
    case 'agriculture':
      return Icons.agriculture;
    case 'forest':
      return Icons.park; // no direct 'forest', use park
    case 'light_mode':
      return Icons.light_mode;
    case 'oil_barrel':
      return Icons.oil_barrel;
    case 'electric_bolt':
      return Icons.electrical_services; // closest match
    case 'hvac':
      return Icons.hvac;
    case 'iron':
      return Icons.hardware;
    case 'volcano':
      return Icons.landslide; // approximate
    case 'mood_bad':
      return Icons.mood_bad;
    case 'medical_services':
      return Icons.medical_services;
    case 'coronavirus':
      return Icons.coronavirus;
    case 'filter_drama':
      return Icons.filter_drama;
    case 'trending_down':
      return Icons.trending_down;
    case 'no_crash':
      return Icons.no_crash;
    case 'delete_forever':
      return Icons.delete_forever;
    case 'kitchen':
      return Icons.kitchen;
    case 'directions_run':
      return Icons.directions_run;
    case 'timer':
      return Icons.timer;
    case 'grid_on':
      return Icons.grid_on;
    case 'cell_wifi':
      return Icons.cell_wifi;
    case 'texture':
      return Icons.texture;
    case 'compress':
      return Icons.compress;

    // Add visual/icon helper names used in the app
    case 'bolt':
      return Icons.bolt;
    case 'fireplace':
      return Icons.fireplace;
    case 'sensors':
      return Icons.sensors;
    case 'wb_sunny':
      return Icons.wb_sunny;

    default:
      return Icons.help_outline;
  }
}
