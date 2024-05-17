
import 'package:clock_hive/models/stopwatch.dart';
import 'package:hive/hive.dart';

class StopWatchDatabase{
  Box? box;
  final String boxName = 'stopwatch';
  final String starterKey = 'starter';
  final String timestampsKey = 'timestamps';

  Future<void> open() async {
    box = await Hive.openBox(boxName);
  }

  Future<void> close() async{
    await box!.close();
  }

  Future<StopWatch> get() async {
    int starter = await box!.get(starterKey, defaultValue: 0) as int;
    List<dynamic> rawTimestamps = await box!.get(timestampsKey, defaultValue: []);
    List<int> timestamps = rawTimestamps.cast<int>();
    StopWatch stopWatch = StopWatch(starterMilliseconds: starter, timestamps: timestamps);
    return stopWatch;
  }

  Future<void> store(StopWatch stopWatch) async {
    await box!.put(starterKey, stopWatch.elapsedMillis);
    await box!.put(timestampsKey, stopWatch.timestamps);
  }

  Future<void> clear() async {
    box!.clear();
  }
}