import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:her_flowmate/services/health_tracker_service.dart';
import 'package:her_flowmate/models/daily_log.dart';

class MockBox extends Mock implements Box<DailyLog> {}

void main() {
  group('HealthTrackerService Tests', () {
    late HealthTrackerService service;
    late MockBox mockBox;

    setUp(() {
      mockBox = MockBox();
      service = HealthTrackerService(unitTestBox: mockBox);
    });

    test('getDailyLog uses correct YYYY-MM-DD key format', () {
      final date = DateTime(2024, 4, 14);
      final expectedKey = "2024-04-14";
      
      when(() => mockBox.get(expectedKey)).thenReturn(null);
      
      service.getDailyLog(date);
      
      verify(() => mockBox.get(expectedKey)).called(1);
    });

    test('getDailyLogs sorts logs in descending order (newest first)', () {
      final log1 = DailyLog(date: DateTime(2024, 4, 10));
      final log2 = DailyLog(date: DateTime(2024, 4, 12));
      final log3 = DailyLog(date: DateTime(2024, 4, 11));

      when(() => mockBox.values).thenReturn([log1, log2, log3]);

      final result = service.getDailyLogs();

      expect(result.length, 3);
      expect(result[0].date, DateTime(2024, 4, 12));
      expect(result[1].date, DateTime(2024, 4, 11));
      expect(result[2].date, DateTime(2024, 4, 10));
    });

    test('getCheckinStreak calculates correct streak when today is logged', () {
      final today = DateTime.now();
      final todayLog = DailyLog(date: today);
      final yesterdayLog = DailyLog(date: today.subtract(const Duration(days: 1)));
      final twoDaysAgoLog = DailyLog(date: today.subtract(const Duration(days: 2)));

      final todayKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayKey = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final twoDaysAgoKey = "${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}";
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final threeDaysAgoKey = "${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}";

      when(() => mockBox.get(todayKey)).thenReturn(todayLog);
      when(() => mockBox.get(yesterdayKey)).thenReturn(yesterdayLog);
      when(() => mockBox.get(twoDaysAgoKey)).thenReturn(twoDaysAgoLog);
      when(() => mockBox.get(threeDaysAgoKey)).thenReturn(null);

      expect(service.getCheckinStreak(), 3);
    });

    test('getCheckinStreak continues from yesterday if today is not yet logged', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayLog = DailyLog(date: yesterday);
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final twoDaysAgoLog = DailyLog(date: twoDaysAgo);

      final todayKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final yesterdayKey = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
      final twoDaysAgoKey = "${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}";
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final threeDaysAgoKey = "${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}";

      when(() => mockBox.get(todayKey)).thenReturn(null);
      when(() => mockBox.get(yesterdayKey)).thenReturn(yesterdayLog);
      when(() => mockBox.get(twoDaysAgoKey)).thenReturn(twoDaysAgoLog);
      when(() => mockBox.get(threeDaysAgoKey)).thenReturn(null);

      expect(service.getCheckinStreak(), 2);
    });
  });
}
