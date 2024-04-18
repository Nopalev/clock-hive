import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final List<String> routes = [
    '/alarm',
    '/clock',
    '/stopwatch',
    '/timer'
  ];

  void onDestinationSelected(int index){
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Timer',
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
      body: const Placeholder(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100)
        ),
        child: const Icon(Icons.play_arrow),
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
          selectedIndex: 3,
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
