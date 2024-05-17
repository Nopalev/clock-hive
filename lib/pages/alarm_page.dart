import 'package:clock_hive/methods/app_bar.dart';
import 'package:clock_hive/methods/navigation_bar.dart';
import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Alarm'),
      bottomNavigationBar: navigationBar(context, 0),
    );
  }
}
