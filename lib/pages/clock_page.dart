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
  Timer? t;
  Clock clock = Clock(now: DateTime.now());
  bool isLoading = true;

  List<WorldTime>? worldtimes;

  void initClock() async {
    box = await Hive.openBox('worldtime');

    dynamic data = box!.get('timezones');
    if(data != null) {
      worldtimes = List<WorldTime>.from(data);
    }
    else{
      worldtimes = [
        WorldTime(url: 'Asia/Jakarta'),
        WorldTime(url: 'Asia/Tokyo'),
        WorldTime(url: 'Asia/Kathmandu'),
        WorldTime(url: 'America/Los_Angeles')
      ];
    }
    await box!.close();

    if(worldtimes != null) {
      for (var worldtime in worldtimes!) {
        await worldtime.getTime();
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
        if(worldtimes != null) {
          for (var worldtime in worldtimes!) {
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
              clock.date(),
              style: const TextStyle(
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 20),
            (worldtimes == null) ? const SizedBox(height: 20) :
            Expanded(
              child: ListView.builder(
                itemCount: worldtimes!.length,
                itemBuilder: (context, index){
                  return Center(
                    child: ListTile(
                      title: Center(
                        child: Text(
                          worldtimes![index].formatted(),
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Text(
                            '${worldtimes![index].timezone()}, ${worldtimes![index].date()}',
                            style: const TextStyle(
                                fontSize: 12
                            ),
                          ),
                          Text(
                            worldtimes![index].offset(),
                            style: const TextStyle(
                                fontSize: 12
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () async{
                          box = await Hive.openBox('worldtime');
                          worldtimes!.removeAt(index);
                          box!.put('worldtime', worldtimes);
                          await box!.close();
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
            box = await Hive.openBox('worldtime');
            worldtimes!.clear();
            box!.put('worldtime', worldtimes);
            await box!.close();
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
                box = await Hive.openBox('worldtime');
                WorldTime instance =  WorldTime(url: result['url']);
                instance.getTime();
                worldtimes!.add(instance);
                box!.put('worldtime', worldtimes);
                await box!.close();
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
