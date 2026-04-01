import 'package:flutter_test/flutter_test.dart';
import 'package:her_flowmate/models/period_log.dart';
import 'package:her_flowmate/models/cycle_engine.dart';

void main() {
  group('CycleEngine Tests', () {
    test('calculateAverageCycleLength returns 28 for empty logs', () {
      expect(CycleEngine.calculateAverageCycleLength([]), 28);
    });

    test('calculateAverageCycleLength calculates correct average', () {
      final logs = [
        PeriodLog(startDate: DateTime(2024, 3, 1), duration: 5),
        PeriodLog(startDate: DateTime(2024, 2, 1), duration: 5), // 29 days
        PeriodLog(startDate: DateTime(2024, 1, 3), duration: 5), // 29 days
      ];
      expect(CycleEngine.calculateAverageCycleLength(logs), 29);
    });

    test('detectIrregularity identifies irregular cycles', () {
      final logs = [
        PeriodLog(startDate: DateTime(2024, 4, 1), duration: 5),
        PeriodLog(startDate: DateTime(2024, 3, 1), duration: 5), // 31 days
        PeriodLog(startDate: DateTime(2024, 2, 8), duration: 5), // 22 days
      ];
      // diff is 9 > 7
      expect(CycleEngine.detectIrregularity(logs), true);
    });

    test('getPhaseForDate identifies Menstrual phase', () {
      final logs = [PeriodLog(startDate: DateTime(2024, 3, 1), duration: 5)];
      final date = DateTime(2024, 3, 3);
      expect(CycleEngine.getPhaseForDate(date, logs, 28), CyclePhase.menstrual);
    });

    test('getPhaseForDate identifies Follicular phase', () {
      final logs = [PeriodLog(startDate: DateTime(2024, 3, 1), duration: 5)];
      final date = DateTime(2024, 3, 7); // Day 7
      // Ovulation day = 28 - 14 = 14.
      // Follicular is < ovulationDay - 5 (9)
      expect(
        CycleEngine.getPhaseForDate(date, logs, 28),
        CyclePhase.follicular,
      );
    });

    test('calculateHormones returns valid mapping', () {
      final hormones = CycleEngine.calculateHormones(14, 28);
      expect(hormones.containsKey('Estrogen'), true);
      expect(hormones.containsKey('Progesterone'), true);
      expect(hormones['Estrogen'], isNotNull);
      expect(hormones['LH'], greaterThan(0.8)); // LH surge at ovulation
    });
  });
}
