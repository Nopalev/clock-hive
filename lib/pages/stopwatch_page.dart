import 'package:clock_hive/components/floating_action_button.dart';
import 'package:clock_hive/database/stopwatch_database.dart';
import 'package:clock_hive/components/app_bar.dart';
import 'package:clock_hive/components/error_dialog.dart';
import 'package:clock_hive/components/navigation_bar.dart';
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
  List<int> timestamps = [];
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
    showDialog(
        context: context,
        barrierDismissible: false, // disables popup to close if tapped outside popup (need a button to close)
        builder: (BuildContext context) {
          return ErrorDialog(errorMessage: errorMessage);
        }
    );
    setState(() {
      error = false;
    });
  }

  String timeDifference(int timeInMilli, int timeFrom){
    int elapsedMillis = timeFrom - timeInMilli;
    String milliseconds = (elapsedMillis % 1000).toString().padLeft(3, "0");
    String seconds = ((elapsedMillis ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((elapsedMillis ~/ 1000) ~/ 60).toString().padLeft(2, "0");

    return "+$minutes:$seconds:$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Stopwatch'),
      body: (isLoading) ?
      const CircularProgressIndicator() :
      Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              stopWatch.formatted(stopWatch.elapsedMillis),
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
                        stopWatch.formatted(timestamps[index]),
                        style: const TextStyle(
                            fontSize: 12,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      title: Text(
                        (timestamps.length - index == 1) ?
                        timeDifference(0, timestamps[index]):
                        timeDifference(timestamps[index+1], timestamps[index]),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400
                        ),
                        textAlign: TextAlign.center,
                      ),
                      trailing: Text(
                        (timestamps.length - index).toString(),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
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
          CustomFAB(
            heroTag: 'record',
            onPressed: () async {
              stopWatch.record();
              await stopWatchDatabase.store(stopWatch);
            },
            icon: const Icon(Icons.flag)
          ),
          CustomFAB(
            heroTag: 'stop',
            onPressed: () async {
              stopWatch.stop();
              await stopWatchDatabase.store(stopWatch);
            },
            icon: const Icon(Icons.stop),
          ),
        ],
      ) :
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomFAB(
            heroTag: 'reset',
            onPressed: () async {
              stopWatch.reset();
              timestamps.clear();
              await stopWatchDatabase.store(stopWatch);
            },
            icon: const Icon(Icons.clear),
          ),
          CustomFAB(
            heroTag: 'start',
            onPressed: () async {
              stopWatch.start();
              await stopWatchDatabase.store(stopWatch);
            },
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 2),
    );
  }
}
