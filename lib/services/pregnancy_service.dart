import 'package:flutter/foundation.dart';
import 'base_storage_service.dart';

class PregnancyService extends ChangeNotifier {
  final BaseStorageService _base = BaseStorageService.instance;

  DateTime? get dueDate {
    final ms = _base.prefs.getInt('dueDate');
    if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);

    final cDate = conceptionDate;
    if (cDate != null) return cDate.add(const Duration(days: 280));
    return null;
  }

  DateTime? get conceptionDate {
    final ms = _base.prefs.getInt('conceptionDate');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> savePregnancyData({DateTime? conceptionDate, int? weeks}) async {
    if (conceptionDate != null) {
      await _base.prefs.setInt(
        'conceptionDate',
        conceptionDate.millisecondsSinceEpoch,
      );
      await _base.prefs.remove('pregnancyWeeks');
    } else if (weeks != null && weeks > 0) {
      final derivedConception = DateTime.now().subtract(
        Duration(days: weeks * 7),
      );
      await _base.prefs.setInt(
        'conceptionDate',
        derivedConception.millisecondsSinceEpoch,
      );
      await _base.prefs.setInt('pregnancyWeeks', weeks);
    }
    notifyListeners();
  }

  Future<void> saveDueDate(DateTime date) async {
    await _base.prefs.setInt('dueDate', date.millisecondsSinceEpoch);
    notifyListeners();
  }
}
