import 'package:clock_hive/database/stopwatch_database.dart';
import 'package:clock_hive/methods/app_bar.dart';
import 'package:clock_hive/methods/error_dialog.dart';
import 'package:clock_hive/methods/navigation_bar.dart';
import 'package:clock_hive/models/stopwatch.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  StopWatchDatabase stopWatchDatabase = StopWatchDatabase();
  StopWatch stopWatch = StopWatch();
  List<String> timestamps = [];
  Timer? t;
  bool isLoading = true;
  bool error = false;
  String errorMessage = '';

  void loadingWrap(void Function() func){
    setState(() {
      isLoading = true;
    });
    func();
    setState(() {
      isLoading = false;
    });
  }

  void storeAndClose() async {
    await stopWatchDatabase.store(stopWatch);
    stopWatchDatabase.close();
  }

  @override
  void initState() {
    super.initState();

    loadingWrap(() async {
      await stopWatchDatabase.open();
      stopWatch = await stopWatchDatabase.get();
    });

    if(mounted){
      t = Timer.periodic(const Duration(milliseconds: 20), (timer) {
        setState(() {
          timestamps = stopWatch.timeStamps;
        });
      });
    }
  }

  @override
  void dispose() {
    t!.cancel();
    storeAndClose();
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
      appBar: appBar('Stopwatch'),
      body: (isLoading) ?
      const CircularProgressIndicator() :
      Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              stopWatch.formatted(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 48
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timestamps.length,
                itemBuilder: (context, index){
                  return Center(
                    child: ListTile(
                      leading: Text(
                        (index+1).toString(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                      title: Text(
                        timestamps[index],
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w400
                        ),
                        textAlign: TextAlign.center,
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          loadingWrap(() async {
                            stopWatch.removeTimestamp(index);
                            await stopWatchDatabase.store(stopWatch);
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                }
              ),
            ),
            const SizedBox(height: 80)
          ],
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (isLoading) ?
      null :
      (stopWatch.isRunning) ?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'record',
            onPressed: () async {
              stopWatch.record();
              await stopWatchDatabase.store(stopWatch);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.flag),
          ),
          FloatingActionButton(
            heroTag: 'stop',
            onPressed: () async {
              stopWatch.stop();
              await stopWatchDatabase.store(stopWatch);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.stop),
          ),
        ],
      ) :
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () async {
              stopWatch.reset();
              timestamps.clear();
              await stopWatchDatabase.store(stopWatch);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.clear),
          ),
          FloatingActionButton(
            heroTag: 'start',
            onPressed: () async {
              stopWatch.start();
              await stopWatchDatabase.store(stopWatch);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      bottomNavigationBar: navigationBar(context, 2),
    );
  }
}
