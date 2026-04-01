import 'package:flutter_test/flutter_test.dart';
import 'package:her_flowmate/models/period_log.dart';
import 'package:her_flowmate/services/prediction_service.dart';
import 'package:her_flowmate/services/storage_service.dart';

class FakeStorageService extends StorageService {
  FakeStorageService() : super.internal();
  List<PeriodLog> logs = [];

  @override
  List<PeriodLog> getLogs() => logs;
}

void main() {
  group('PredictionService Tests', () {
    late FakeStorageService fakeStorage;
    late PredictionService predictionService;

    setUp(() {
      fakeStorage = FakeStorageService();
      predictionService = PredictionService(fakeStorage);
    });

    test('averageCycleLength returns 28 for less than 2 logs', () {
      fakeStorage.logs = [];
      expect(predictionService.averageCycleLength, 28);

      fakeStorage.logs = [PeriodLog(startDate: DateTime.now(), duration: 5)];
      expect(predictionService.averageCycleLength, 28);
    });

    test(
      'averageCycleLength correctly calculates average of cycles and ignores outliers',
      () {
        final now = DateTime.now();
        // Add logs: newest to oldest
        fakeStorage.logs = [
          PeriodLog(startDate: now, duration: 5), // Cycle 1 start
          PeriodLog(
            startDate: now.subtract(const Duration(days: 30)),
            duration: 5,
          ), // Cycle 2 start (30 day diff)
          PeriodLog(
            startDate: now.subtract(const Duration(days: 58)),
            duration: 5,
          ), // Cycle 3 start (28 day diff)
          PeriodLog(
            startDate: now.subtract(const Duration(days: 158)),
            duration: 5,
          ), // outlier (100 day diff! ignored)
        ];

        // Standard cycles are 30 and 28. (30 + 28) / 2 = 29.
        expect(predictionService.averageCycleLength, 29);
      },
    );

    test('currentPhase identifies menstrual phase accurately', () {
      final now = DateTime.now();
      fakeStorage.logs = [
        PeriodLog(
          startDate: now.subtract(const Duration(days: 2)),
          duration: 5,
        ),
      ];

      expect(predictionService.currentPhase, CyclePhase.menstrual);
      expect(predictionService.phaseDisplayName, 'Menstruation');
    });

    test('currentPhase identifies follicular phase accurately', () {
      final now = DateTime.now();
      fakeStorage.logs = [
        // 9 days since period start, assuming 28 day average cycle, ovulation is day 14.
        // Luteal is last 14 days. Extends from day 5 to day 9 (ovulation - 5).
        PeriodLog(
          startDate: now.subtract(const Duration(days: 8)),
          duration: 5,
        ),
      ];

      expect(predictionService.currentPhase, CyclePhase.follicular);
      expect(predictionService.phaseDisplayName, 'Follicular');
    });

    test('currentPhase identifies luteal phase accurately', () {
      final now = DateTime.now();
      fakeStorage.logs = [
        // 20 days since start, well past ovulation
        PeriodLog(
          startDate: now.subtract(const Duration(days: 20)),
          duration: 5,
        ),
      ];

      expect(predictionService.currentPhase, CyclePhase.luteal);
      expect(predictionService.phaseDisplayName, 'Luteal');
    });

    test(
      'isFertileDay correctly flags days within the 5-day ovulation window',
      () {
        final now = DateTime.now();
        fakeStorage.logs = [
          PeriodLog(startDate: now, duration: 5),
          PeriodLog(
            startDate: now.subtract(const Duration(days: 28)),
            duration: 5,
          ), // average 28
        ];

        final day5 = now.add(const Duration(days: 5)); // Safe
        final day10 = now.add(const Duration(days: 10)); // Fertile (14 - 4)
        final day14 = now.add(
          const Duration(days: 14),
        ); // Peak Ovulation (Fertile)
        final day20 = now.add(const Duration(days: 20)); // Safe Luteal

        expect(predictionService.isFertileDay(day5), false);
        expect(predictionService.isFertileDay(day10), true);
        expect(predictionService.isFertileDay(day14), true);
        expect(predictionService.isFertileDay(day20), false);
      },
    );

    test('daysUntilNextPeriod predicts safely for standard cycles', () {
      final now = DateTime.now();
      // Mock exactly one period, average will fall to default 28.
      fakeStorage.logs = [
        PeriodLog(
          startDate: now.subtract(const Duration(days: 20)),
          duration: 5,
        ),
      ];
      // 28 - 20 = 8 days left
      expect(predictionService.daysUntilNextPeriod, 8);
    });
  });
}
