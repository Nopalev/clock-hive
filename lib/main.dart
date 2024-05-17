import 'package:clock_hive/models/worldtime.dart';
import 'package:clock_hive/pages/add_timezone.dart';
import 'package:clock_hive/pages/alarm_page.dart';
import 'package:clock_hive/pages/clock_page.dart';
import 'package:clock_hive/pages/stopwatch_page.dart';
import 'package:clock_hive/pages/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  await Hive.initFlutter();
  Hive.registerAdapter(WorldTimeAdapter());
  Map<String, Widget Function(BuildContext)> routes = {
    '/alarm': (context) => const AlarmPage(),
    '/clock': (context) => const ClockPage(),
    '/stopwatch': (context) => const StopwatchPage(),
    '/timer': (context) => const TimerPage(),
    '/add_timezone': (context) => const AddTimezone()
  };

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    theme: ThemeData.dark(),
    initialRoute: '/clock',
    routes: routes,
  ));
}