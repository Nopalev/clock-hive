import 'package:flutter/material.dart';

Widget navigationBar(context, int selectedIndex){
  List<String> routes = [
    '/alarm',
    '/clock',
    '/stopwatch',
    '/timer'
  ];
  return NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: (int index){
      Navigator.pushReplacementNamed(context, routes[index]);
    },
    destinations: const <Widget>[
      NavigationDestination(
        icon: Icon(
          Icons.alarm,
        ),
        label: 'Alarm',
      ),
      NavigationDestination(
          icon: Icon(
            Icons.access_time,
          ),
          label: 'Clock'
      ),
      NavigationDestination(
          icon: Icon(
            Icons.timer_outlined,
          ),
          label: 'Stopwatch'
      ),
      NavigationDestination(
          icon: Icon(
            Icons.hourglass_bottom,
          ),
          label: 'Timer'
      )
    ],
  );
}