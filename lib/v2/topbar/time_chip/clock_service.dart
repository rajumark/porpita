import 'dart:async';

class ClockService {
  static final ClockService _instance = ClockService._();
  factory ClockService() => _instance;
  ClockService._();

  Timer? _timer;
  DateTime _now = DateTime.now();

  final _controller = StreamController<DateTime>.broadcast();
  Stream<DateTime> get stream => _controller.stream;

  DateTime get current => _now;

  void start() {
    _timer?.cancel();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _update());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _update() {
    _now = DateTime.now();
    _controller.add(_now);
  }

  String formatHourMinute() {
    final h = _now.hour;
    final m = _now.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }
}