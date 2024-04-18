import 'dart:async';
import 'package:clock_hive/model/stopwatch.dart';
import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final List<String> routes = [
    '/alarm',
    '/clock',
    '/stopwatch',
    '/timer'
  ];
  bool isStart = false;
  StopwatchModel? stopwatchModel;
  Timer? t;

  void initStopwatch(){
    stopwatchModel = StopwatchModel(timestamp: Stopwatch(), timestamps: []);
  }

  @override
  void initState() {
    super.initState();
    initStopwatch();

    t = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void onDestinationSelected(int index){
    t?.cancel();
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  void start(){
    if(mounted) {
      setState(() {
        isStart = true;
        stopwatchModel?.timestamp.start();
      });
    }
  }

  void stop(){
    if(mounted) {
      setState(() {
        isStart = false;
        stopwatchModel?.timestamp.stop();
        print(stopwatchModel?.timestamps);
      });
    }
  }

  void record(){
    if(mounted){
      setState(() {
        Stopwatch timestamp = stopwatchModel!.timestamp;
        stopwatchModel?.timestamps?.add(timestamp);
      });
    }
  }

  void delete(){
    if(mounted) {
      setState(() {
        isStart = false;
        stopwatchModel?.timestamp.reset();
        stopwatchModel?.timestamps?.clear();
      });
    }
  }

  String returnFormattedText(int timestamp) {
    String milliseconds = (timestamp % 1000).toString().padLeft(3, "0"); // this one for the miliseconds
    String seconds = ((timestamp ~/ 1000) % 60).toString().padLeft(2, "0"); // this is for the second
    String minutes = ((timestamp ~/ 1000) ~/ 60).toString().padLeft(2, "0"); // this is for the minute

    return "$minutes:$seconds:$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stopwatch',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget> [
          IconButton(
              onPressed: () => {},
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 18,
              )
          )
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget> [
            Text(
              returnFormattedText(stopwatchModel!.timestamp.elapsedMilliseconds),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (!isStart) ? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'deleteButton',
            onPressed: delete,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.delete),
          ),
          FloatingActionButton(
            heroTag: 'startButton',
            onPressed: start,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.play_arrow),
          ),
        ],
      ) :
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget> [
          FloatingActionButton(
            heroTag: 'recordButton',
            onPressed: record,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.flag),
          ),
          FloatingActionButton(
            heroTag: 'stopButton',
            onPressed: stop,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Icon(Icons.rectangle),
          )
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) => states.contains(MaterialState.selected)
                ? const TextStyle(color: Colors.blue)
                : const TextStyle(color: Colors.white70),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.black38,
          indicatorColor: Colors.white70,
          indicatorShape: const CircleBorder(),
          selectedIndex: 2,
          destinations: const <Widget> [
            NavigationDestination(
              selectedIcon: Icon(Icons.access_alarm),
              icon: Icon(Icons.access_alarm_outlined),
              label: 'Alarm',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.access_time),
              icon: Icon(Icons.access_time_outlined),
              label: 'Clock',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.timer),
              icon: Icon(Icons.timer_outlined),
              label: 'Stopwatch',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.hourglass_bottom),
              icon: Icon(Icons.hourglass_bottom_outlined),
              label: 'Timer',
            ),
          ],
        ),
      ),
    );
  }
}
