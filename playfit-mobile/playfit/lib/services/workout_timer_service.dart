import 'dart:async';

class WorkoutTimerService {
  static final WorkoutTimerService _instance = WorkoutTimerService._internal();
  factory WorkoutTimerService() => _instance;

  WorkoutTimerService._internal();

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  Function(Duration)? onTick;

  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _ticker = Timer.periodic(Duration(seconds: 1), (_) {
        if (onTick != null) onTick!(_stopwatch.elapsed);
      });
    }
  }

  void stop() {
    _stopwatch.stop();
    _ticker?.cancel();
  }

  void reset() {
    _stopwatch.reset();
  }

  Duration get elapsed => _stopwatch.elapsed;
}
