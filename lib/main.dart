import 'package:clock_hive/pages/add_timezone.dart';
import 'package:clock_hive/pages/clock_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  await Hive.initFlutter();
  Map<String, Widget Function(BuildContext)> routes = {
    '/clock': (context) => const ClockPage(),
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