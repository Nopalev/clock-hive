// ignore_for_file: unused_import

import 'package:clock_hive/services/get_timezones.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:clock_hive/models/worldtime.dart';

class AddTimezone extends StatefulWidget {
  const AddTimezone({super.key});

  @override
  State<AddTimezone> createState() => _AddTimezoneState();
}

class _AddTimezoneState extends State<AddTimezone> {
  List<String>? timezones;
  bool isLoading = true;

  void initTimezones() async{
    timezones = await getTimezones();

    setState(() {
      isLoading = false;
    });
  }

  void addInstance(int index){
    Navigator.pop(context, {
      'url': timezones![index]
    });
  }

  @override
  void initState() {
    super.initState();
    initTimezones();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Timezone',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
          centerTitle: true,
      ),
      body: Center(
        child: (isLoading) ?
        const CircularProgressIndicator() :
        ListView.builder(
          itemCount: timezones!.length,
          itemBuilder: (context, index){
            return ListTile(
              title: Text(
                timezones![index]
              ),
              onTap:() {addInstance(index);},
            );
          }
        ),
      ),
    );
  }
}
