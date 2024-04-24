import 'package:clock_hive/models/clock.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:clock_hive/models/worldtime.dart';


class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  Box? box;
  String boxName = 'worldtime';
  String keyName = 'timezones';
  Timer? t;
  Clock clock = Clock(now: DateTime.now());
  bool isLoading = true;

  List<String> timezones = [];
  Map<String, WorldTime> worldtimes = {};

  void initClock() async {
    box = await Hive.openBox(boxName);
    timezones = List<String>.from(await box!.get(keyName, defaultValue: []));
    await box!.close();

    if(timezones.isNotEmpty) {
      for (var timezone in timezones) {
        WorldTime instance = WorldTime(url: timezone);
        await instance.getTime();
        worldtimes[timezone] = instance;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initClock();

    t = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        clock.renew();
        if(worldtimes.isNotEmpty) {
          for (var worldtime in worldtimes.values) {
            worldtime.renew();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clock',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: (isLoading) ?
        const CircularProgressIndicator() :
        Column(
          children: <Widget> [
            const SizedBox(height: 20),
            Text(
              clock.formatted(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 48
              ),
            ),
            Text(
              '${clock.date()}, ${clock.offset()}',
              style: const TextStyle(
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 20),
            (worldtimes.isEmpty) ? const SizedBox(height: 20) :
            Expanded(
              child: ListView.builder(
                itemCount: worldtimes.length,
                itemBuilder: (context, index){
                  return Center(
                    child: ListTile(
                      title: Center(
                        child: Text(
                          worldtimes[timezones[index]]!.formatted(),
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Text(
                            '${worldtimes[timezones[index]]!.timezone()}, ${worldtimes[timezones[index]]!.date()}',
                            style: const TextStyle(
                                fontSize: 12
                            ),
                          ),
                          Text(
                            worldtimes[timezones[index]]!.offset(),
                            style: const TextStyle(
                                fontSize: 12
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () async{
                          setState(() {
                            isLoading = true;
                          });
                          box = await Hive.openBox(boxName);
                          worldtimes.remove(timezones[index]);
                          timezones.removeAt(index);
                          await box!.put(keyName, timezones);
                          await box!.close();
                          setState(() {
                            isLoading = false;
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                }
              )
            ),
            const SizedBox(height: 80)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        FloatingActionButton(
          heroTag: 'deleteAllButton',
          onPressed: () async{
            setState(() {
              isLoading = true;
            });
            box = await Hive.openBox(boxName);
            worldtimes.clear();
            timezones.clear();
            await box!.clear();
            await box!.close();
            setState(() {
              isLoading = false;
            });
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100)
          ),
          child: const Icon(Icons.clear),
        ),
          FloatingActionButton(
            heroTag: 'addButton',
            onPressed: () async{
              dynamic result = await Navigator.pushNamed(context, '/add_timezone');
              if(result != null){
                setState(() {
                  isLoading = true;
                });
                box = await Hive.openBox(boxName);
                String url = result['url'];
                WorldTime instance =  WorldTime(url: url);
                await instance.getTime();
                worldtimes[url] = instance;
                if (!timezones.contains(url)){
                  timezones.add(url);
                }
                await box!.put(keyName, timezones);
                await box!.close();
                setState(() {
                  isLoading = false;
                });
              }
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
