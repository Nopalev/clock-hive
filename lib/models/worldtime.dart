import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class WorldTime {
  final String? url;

  DateTime? time;
  String? timeDifference;
  String? offsetSign;
  int? offsetHours;
  int? offsetMinutes;
  bool? dayTime;

  WorldTime({
    required this.url
  });

  Future<void> getTime() async{

    try{
      Response response = await get(Uri.parse('https://worldtimeapi.org/api/timezone/$url'));
      Map data = jsonDecode(response.body);
      offsetSign = data['utc_offset'].substring(0, 1);
      offsetHours = int.parse(data['utc_offset'].substring(1, 3));
      offsetMinutes = int.parse(data['utc_offset'].substring(4, 6));

      time = DateTime.now().toUtc();
      if(offsetSign == '+'){
        time = time!.add(Duration(hours: offsetHours!.toInt(), minutes: offsetMinutes!.toInt()));
      }
      else if(offsetSign == '-'){
        time = time!.subtract(Duration(hours: offsetHours!.toInt(), minutes: offsetMinutes!.toInt()));
      }
      isDay();

    }catch(e){
      return Future.error(e);
    }
  }

  void renew(){
    time = DateTime.now().toUtc();
    if(offsetSign == '+'){
      time = time!.add(Duration(hours: offsetHours!.toInt(), minutes: offsetMinutes!.toInt()));
    }
    else if(offsetSign == '-'){
      time = time!.subtract(Duration(hours: offsetHours!.toInt(), minutes: offsetMinutes!.toInt()));
    }
    isDay();
  }

  String formatted(){
    return DateFormat.jm().format(time!);
  }

  String date(){
    return DateFormat('dd/MM/yyyy').format(time!);
  }

  String timezone(){
    List<String> regions = [
      'Africa',
      'America',
      'Antarctica',
      'Asia',
      'Atlantic',
      'Europe',
      'Indian',
      'Pacific'
    ];

    List<String> splitted = url.toString().split('/');

    if(regions.contains(splitted[0])){
      List<String> city = splitted.last.split('_');
      return city.join(' ');
    }
    return url.toString();
  }

  void difference(DateTime now){
    int minutesDiff = (time!.hour - now.hour)*60 + (time!.minute - now.minute);
    Duration difference = Duration(minutes: minutesDiff);
    String output = 'Failed to compute difference';

    if(difference.inMinutes == 0){
      output = 'Same as local time';
    }
    else if(difference.inMinutes < 0){
      int hours = difference.inHours.abs();
      int minutes = difference.inMinutes.abs()%60;
      if(hours == 1) {
        output = '1 hour ';
      }
      else if(hours != 0){
        output = '$hours hours ';
      }
      if (minutes != 0){
        output += 'and $minutes minutes ';
      }
      if(hours == 0){
        output = '$minutes minutes ';
      }
      output += 'late from local time';
    }
    else{
      int hours = difference.inHours.abs();
      int minutes = difference.inMinutes.abs()%60;
      if(hours == 1) {
        output = '1 hour ';
      }
      else if(hours != 0){
        output = '$hours hours ';
      }
      if (minutes != 0){
        output += 'and $minutes minutes ';
      }
      if(hours == 0){
        output = '$minutes minutes ';
      }
      output += 'ahead of local time';
    }
    timeDifference = output;
  }

  void isDay(){
    dayTime = (time!.hour >= 6 && time!.hour <= 17) ? true : false;
  }
}