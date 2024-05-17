import 'package:clock_hive/components/app_bar.dart';
import 'package:clock_hive/components/navigation_bar.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Timer'),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3),
    );
  }
}
