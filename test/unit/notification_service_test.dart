import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/services/notification_service.dart';

void main() {
  group('NotificationService.getAlertForLevels', () {
    // ── No alert ──────────────────────────────────────────────────────────────
    test('returns null when both PM10 and PM25 are below all thresholds', () {
      expect(NotificationService.getAlertForLevels(0, 0), isNull);
    });

    test('returns null just below the Alerta Ambiental PM10 threshold (139.9)',
        () {
      expect(NotificationService.getAlertForLevels(139.9, 0), isNull);
    });

    test('returns null just below the Alerta Ambiental PM25 threshold (69.9)',
        () {
      expect(NotificationService.getAlertForLevels(0, 69.9), isNull);
    });

    // ── Alerta Ambiental ──────────────────────────────────────────────────────
    test('returns Alerta Ambiental exactly at PM10 threshold (140)', () {
      final alert = NotificationService.getAlertForLevels(140, 0);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.alerta);
      expect(alert.title, contains('Alerta Ambiental'));
    });

    test('returns Alerta Ambiental exactly at PM25 threshold (70)', () {
      final alert = NotificationService.getAlertForLevels(0, 70);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.alerta);
      expect(alert.title, contains('Alerta Ambiental'));
    });

    test('returns Alerta Ambiental just below Fase I PM10 threshold (164.9)',
        () {
      final alert = NotificationService.getAlertForLevels(164.9, 0);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.alerta);
      expect(alert.title, contains('Alerta Ambiental'));
    });

    test('returns Alerta Ambiental just below Fase I PM25 threshold (84.9)',
        () {
      final alert = NotificationService.getAlertForLevels(0, 84.9);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.alerta);
      expect(alert.title, contains('Alerta Ambiental'));
    });

    // ── Contingencia Fase I ───────────────────────────────────────────────────
    test('returns Contingencia Fase I exactly at PM10 threshold (165)', () {
      final alert = NotificationService.getAlertForLevels(165, 0);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase1);
      expect(alert.title, contains('Fase I'));
    });

    test('returns Contingencia Fase I exactly at PM25 threshold (85)', () {
      final alert = NotificationService.getAlertForLevels(0, 85);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase1);
      expect(alert.title, contains('Fase I'));
    });

    test('returns Contingencia Fase I just below Fase II PM10 threshold (214.9)',
        () {
      final alert = NotificationService.getAlertForLevels(214.9, 0);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase1);
      expect(alert.title, contains('Fase I'));
    });

    test('returns Contingencia Fase I just below Fase II PM25 threshold (114.9)',
        () {
      final alert = NotificationService.getAlertForLevels(0, 114.9);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase1);
      expect(alert.title, contains('Fase I'));
    });

    // ── Contingencia Fase II ──────────────────────────────────────────────────
    test('returns Contingencia Fase II exactly at PM10 threshold (215)', () {
      final alert = NotificationService.getAlertForLevels(215, 0);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase2);
      expect(alert.title, contains('Fase II'));
    });

    test('returns Contingencia Fase II exactly at PM25 threshold (115)', () {
      final alert = NotificationService.getAlertForLevels(0, 115);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase2);
      expect(alert.title, contains('Fase II'));
    });

    test('returns Contingencia Fase II well above all thresholds', () {
      final alert = NotificationService.getAlertForLevels(300, 200);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase2);
      expect(alert.title, contains('Fase II'));
    });

    // ── Mixed PM10 / PM25 levels ──────────────────────────────────────────────
    test('uses the highest severity when PM10 triggers Fase II but PM25 is low',
        () {
      final alert = NotificationService.getAlertForLevels(215, 10);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase2);
      expect(alert.title, contains('Fase II'));
    });

    test('uses the highest severity when PM25 triggers Fase II but PM10 is low',
        () {
      final alert = NotificationService.getAlertForLevels(10, 115);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase2);
      expect(alert.title, contains('Fase II'));
    });

    test(
        'returns Fase I when PM10 is in Fase I range and PM25 is below all thresholds',
        () {
      final alert = NotificationService.getAlertForLevels(165, 0);
      expect(alert, isNotNull);
      expect(alert!.level, AlertLevel.fase1);
      expect(alert.title, contains('Fase I'));
    });
  });
}
