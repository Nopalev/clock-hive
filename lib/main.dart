import 'package:clock_hive/pages/alarm_page.dart';
import 'package:clock_hive/pages/clock_page.dart';
import 'package:clock_hive/pages/stopwatch_page.dart';
import 'package:clock_hive/pages/timer_page.dart';
import 'package:flutter/material.dart';

void main(){
  Map<String, Widget Function(BuildContext)> routes = {
    '/alarm': (context) => AlarmPage(),
    '/clock': (context) => ClockPage(),
    '/stopwatch': (context) => StopwatchPage(),
    '/timer': (context) => TimerPage()
  };

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    theme: ThemeData.dark(),
    initialRoute: '/clock',
    routes: routes,
  ));
}