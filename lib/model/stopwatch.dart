const String box = 'stopwatch';

class StopwatchModel {
  final Stopwatch timestamp;
  final List<Stopwatch>? timestamps;

  const StopwatchModel({
    required this.timestamp,
    this.timestamps
  });
}