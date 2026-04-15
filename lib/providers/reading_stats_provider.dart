import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only counters: time in reader and how often books were opened.
class ReadingStatsProvider extends ChangeNotifier {
  static const _kSeconds = 'reading_stats_total_seconds';
  static const _kOpens = 'reading_stats_reader_opens';

  int _totalSeconds = 0;
  int _readerOpens = 0;

  int get totalSeconds => _totalSeconds;
  int get readerOpens => _readerOpens;

  String get formattedTotalTime {
    final h = _totalSeconds ~/ 3600;
    final m = (_totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '${_totalSeconds}s';
  }

  ReadingStatsProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _totalSeconds = p.getInt(_kSeconds) ?? 0;
    _readerOpens = p.getInt(_kOpens) ?? 0;
    notifyListeners();
  }

  Future<void> registerReaderOpen() async {
    _readerOpens += 1;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kOpens, _readerOpens);
  }

  Future<void> addElapsedSeconds(int seconds) async {
    if (seconds <= 0) return;
    _totalSeconds += seconds;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kSeconds, _totalSeconds);
  }
}
