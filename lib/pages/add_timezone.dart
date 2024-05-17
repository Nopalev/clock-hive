import 'dart:convert';
import 'package:http/http.dart';
import 'package:clock_hive/components/app_bar.dart';
import 'package:flutter/material.dart';

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
      Navigator.pop(context, 'error');
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

  Future<List<String>> getTimezones() async {
    try{
      Response response = await get(Uri.parse('https://worldtimeapi.org/api/timezone'));
      List<String> data = List<String>.from(jsonDecode(response.body));
      return data;
    }
    catch(e){
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Timezone'),
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
