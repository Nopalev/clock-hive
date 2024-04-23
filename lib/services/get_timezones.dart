import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

Future<List<String>> getTimezones() async {
  try{
    Response response = await get(Uri.parse('https://worldtimeapi.org/api/timezone'));
    List<String> data = List<String>.from(jsonDecode(response.body));
    return data;
  }
  catch(e){
    rethrow;
  }
}