import 'package:clock_hive/models/worldtime.dart';
import 'package:hive/hive.dart';

class WorldTimeDatabase{
  Box? box;
  final String boxName = 'worldtime';
  final String keyName = 'instances';

  Future<void> open() async {
    box = await Hive.openBox(boxName);
  }

  Future<void> close() async{
    await box!.close();
  }

  Future<Map<String, WorldTime>> getAll() async {
    Map<String, WorldTime> result = {};
    List<dynamic> instances = await box!.get(keyName, defaultValue: []);
    for (var element in instances) {
      WorldTime worldTime = element as WorldTime;
      result[worldTime.url.toString()] = worldTime;
    }
    return result;
  }

  Future<void> store(List<WorldTime> instances) async {
    await box!.put(keyName, instances);
  }

  Future<void> clear() async {
    box!.clear();
  }
}