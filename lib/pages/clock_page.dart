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
  String errorMessage = '';

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
            if(errorMessage.isEmpty){
              errorMessage = 'Failed to fetch $timezone timezone information';
            }
            else{
              errorMessage = 'Failed to fetch several timezone information';
            }
          });
          if(!error) {
            instance.difference(clock.now);
            worldtimes[timezone] = instance;
          }
          else{
            if(mounted) {
              showErrorDialog(context);
            }
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

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'An Error Has Occurred',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 36
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(
                fontSize: 24
            ),
            textAlign: TextAlign.center,
          ),
          //buttons?
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.close
              ),
              onPressed: () { Navigator.of(context).pop(); },
              color: Colors.purple,//closes popup
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      }
    );
    setState(() {
      error = false;
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
              if(result != null && result != 'error'){
                loadingWrap(() async {
                  String url = result['url'];
                  WorldTime instance =  WorldTime(url: url);
                  await instance.getTime().catchError((error, stackTrace) {
                    errorMessage = 'Failed to fetch $url timezone information';
                    this.error = true;
                  });
                  if(!error){
                    instance.difference(clock.now);
                    worldtimes[url] = instance;
                    await box!.put(keyName, List<String>.from(worldtimes.keys));
                  }
                  else{
                    if(context.mounted) {
                      showErrorDialog(context);
                    }
                  }
                });
              }
              else if (result == 'error'){
                error = true;
                errorMessage = 'Failed to fetch timezones';
                if(context.mounted) {
                  showErrorDialog(context);
                }
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
