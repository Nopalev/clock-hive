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
  bool isLoading = false;
  bool error = false;

  Map<String, WorldTime> worldtimes = {};

  void loadingWrap(void Function() func){
    setState(() {
      isLoading = true;
    });
    func();
    setState(() {
      isLoading = false;
    });
  }

  void boxClose() async{
    await box!.close();
  }

  @override
  void initState() {
    super.initState();
    loadingWrap(() async {
      box = await Hive.openBox(boxName);
      List<String> timezones = List<String>.from(await box!.get(keyName, defaultValue: []));

      if(timezones.isNotEmpty) {
        for (var timezone in timezones) {
          WorldTime instance = WorldTime(url: timezone);
          await instance.getTime().catchError((error, stackTrace) {
            this.error = true;
          });
          if(!error) {
            instance.difference(clock.now);
            worldtimes[timezone] = instance;
          }
          else{
            error = false;
          }
        }
      }
    });

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
  void dispose() {
    boxClose();
    super.dispose();
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
                      leading: (worldtimes.values.elementAt(index).dayTime!) ?
                        const Icon(Icons.sunny) :
                        const Icon(Icons.mode_night),
                      title: Text(
                        worldtimes.values.elementAt(index).formatted(),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w400
                        ),
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Column(
                        children: [
                          Text(
                            '${worldtimes.values.elementAt(index).timezone()}, ${worldtimes.values.elementAt(index).date()}',
                            style: const TextStyle(
                                fontSize: 12
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            worldtimes.values.elementAt(index).timeDifference.toString(),
                            style: const TextStyle(
                                fontSize: 12
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          loadingWrap(() async {
                            String key = worldtimes.keys.elementAt(index);
                            worldtimes.remove(key);
                            await box!.put(keyName, List<String>.from(worldtimes.keys));
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
          onPressed: (){
            loadingWrap(() async {
              worldtimes.clear();
              await box!.clear();
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
                loadingWrap(() async {
                  String url = result['url'];
                  WorldTime instance =  WorldTime(url: url);
                  await instance.getTime().catchError((error, stackTrace) {
                    this.error = true;
                  });
                  if(!error){
                    instance.difference(clock.now);
                    worldtimes[url] = instance;
                    await box!.put(keyName, List<String>.from(worldtimes.keys));
                  }
                  else{
                    error = false;
                  }
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
