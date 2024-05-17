class StopWatch extends Stopwatch{
  int starterMilliseconds;
  List<String> timestamps;

  StopWatch({
    this.starterMilliseconds = 0,
    this.timestamps = const []
  });

  get elapsedDuration{
    return Duration(
        microseconds:
        elapsedMicroseconds + (starterMilliseconds * 1000)
    );
  }

  get elapsedMillis{
    return elapsedMilliseconds + starterMilliseconds;
  }

  get timeStamps{
    return timestamps;
  }

  set milliseconds(int timeInMilliseconds){
    starterMilliseconds = timeInMilliseconds;
  }

  String formatted(){
    String milliseconds = (elapsedMillis % 1000).toString().padLeft(3, "0"); // this one for the miliseconds
    String seconds = ((elapsedMillis ~/ 1000) % 60).toString().padLeft(2, "0"); // this is for the second
    String minutes = ((elapsedMillis ~/ 1000) ~/ 60).toString().padLeft(2, "0"); // this is for the minute

    return "$minutes:$seconds:$milliseconds";
  }

  void record(){
    timestamps.add(formatted());
  }

  void removeTimestamp(int index){
    timestamps.removeAt(index);
  }

  @override
  void reset() {
    starterMilliseconds = 0;
    timestamps.clear();
    super.reset();
  }

}