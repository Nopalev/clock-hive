const String box = 'alarm';

class Alarm {
  final String timestamp;
  final String ringtone;
  final String repeat;
  final bool vibrateWhenSounds;
  final bool deleteAfterActive;
  final bool? isActive;
  final String? label;

  const Alarm({
    required this.timestamp,
    required this.ringtone,
    required this.repeat,
    required this.vibrateWhenSounds,
    required this.deleteAfterActive,
    this.label,
    this.isActive
  });
}