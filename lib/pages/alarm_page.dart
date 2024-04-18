import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
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
          'Alarm',
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
          selectedIndex: 0,
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
