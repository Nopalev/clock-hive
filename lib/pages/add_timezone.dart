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
  List<String>? timezones, timezonesShowed;
  bool isLoading = true;

  void initTimezones() async{
    timezones = await getTimezones().catchError((error, stackTrace) {
      return List<String>.from([]);
    });
    if(timezones!.isEmpty && mounted){
      Navigator.pop(context);
    }
    timezonesShowed = timezones;

    setState(() {
      isLoading = false;
    });
  }

  void addInstance(int index){
    Navigator.pop(context, {
      'url': timezonesShowed![index]
    });
  }

  @override
  void initState() {
    super.initState();
    initTimezones();
  }

  void searchTimezone(String query){
    final suggestion = timezones!.where((timezone) {
      final timezoneLower = timezone.toLowerCase();
      final input = query.toLowerCase();
      
      return timezoneLower.contains(input);
    }).toList();

    setState(() {
      timezonesShowed = suggestion;
    });
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
        Column(
          children: [
            TextField(
              onChanged: searchTimezone,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                prefixIcon: const Icon(Icons.search)
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timezonesShowed!.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(
                      timezonesShowed![index]
                    ),
                    onTap:() {addInstance(index);},
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
