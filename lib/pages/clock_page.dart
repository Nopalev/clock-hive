import 'package:clock_hive/database/worldtime_database.dart';
import 'package:clock_hive/models/clock.dart';
import 'package:clock_hive/methods/app_bar.dart';
import 'package:clock_hive/methods/error_dialog.dart';
import 'package:clock_hive/methods/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:clock_hive/models/worldtime.dart';


class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  WorldTimeDatabase worldTimeDatabase = WorldTimeDatabase();
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

  void boxClose() async {
    await worldTimeDatabase.close();
  }

  @override
  void initState() {
    super.initState();
    loadingWrap(() async {
      await worldTimeDatabase.open();
      worldtimes = await worldTimeDatabase.getAll();

      if(worldtimes.isNotEmpty){
        for (WorldTime worldtime in worldtimes.values) {
          await worldtime.init().catchError((error, stackTrace) {
            this.error = true;
            if (errorMessage.isEmpty) {
              errorMessage =
                  'Failed to fetch ${worldtime.url} timezone information';
            } else {
              errorMessage = 'Failed to fetch several timezone information';
            }
          });
          if (!error) {
            worldtime.difference(clock.now);
          } else {
            if (mounted) {
              showErrorDialog(context);
            }
          }
        }
      }
    });

    t = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if(mounted){
        setState(() {
          clock.renew();
          if (worldtimes.isNotEmpty) {
            for (var worldtime in worldtimes.values) {
              worldtime.renew();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    t!.cancel();
    boxClose();
    super.dispose();
  }

  void showErrorDialog(BuildContext context) {
    errorDialog(context, errorMessage);
    setState(() {
      error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Clock'),
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
                            await worldTimeDatabase.store(worldtimes.values.toList());
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
              await worldTimeDatabase.clear();
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
                  await instance.init().catchError((error, stackTrace) {
                    errorMessage = 'Failed to fetch $url timezone information';
                    this.error = true;
                  });
                  if(!error){
                    instance.difference(clock.now);
                    worldtimes[url] = instance;
                    await worldTimeDatabase.store(worldtimes.values.toList());
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
      bottomNavigationBar: navigationBar(context, 1)
    );
  }
}
