import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

part 'worldtime.g.dart';

@HiveType(typeId: 0)
class WorldTime {
  @HiveField(0)
  final String? url;

  DateTime? time;
  String? offsetSign;
  int? offsetHours;
  int? offsetMinutes;

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

    }catch(e){
      rethrow;
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

  String offset(){
    return 'UTC $offsetSign${offsetHours.toString().padLeft(2, '0')}:${offsetMinutes.toString().padLeft(2, '0')}';
  }
}