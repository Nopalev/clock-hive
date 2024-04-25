import 'package:intl/intl.dart';

class Clock {
  DateTime now;

  Clock({
    required this.now
  });

  void renew(){
    now = DateTime.now();
  }

  String formatted(){
    return DateFormat('HH:mm:ss').format(now);
  }

  String date(){
    return DateFormat('EEEE, dd/MM/yyyy').format(now);
  }

  String offset(){
    String offsetSign = (now.timeZoneOffset.isNegative) ? '-' : '+';
    return 'UTC $offsetSign${now.timeZoneOffset.inHours.toString().padLeft(2, '0')}:${(now.timeZoneOffset.inMinutes%60).toString().padLeft(2, '0')}';
  }
}