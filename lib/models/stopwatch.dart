class StopWatch extends Stopwatch{
  int starterMilliseconds;
  List<int> timestamps;

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

  String timeStampAsString(int index){
    return formatted(timestamps[index]);
  }

  String formatted(int milli){
    String milliseconds = (milli % 1000).toString().padLeft(3, "0");
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");

    return "$minutes:$seconds:$milliseconds";
  }

  void record(){
    timestamps.insert(0, elapsedMilliseconds);
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