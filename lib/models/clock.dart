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
    return DateFormat('dd/MM/yyyy').format(now);
  }
}