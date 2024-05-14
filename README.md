# Clock Hive

A personal Flutter project. This project is a clock application that also stores some clocks at different timezones.

> This version of wiki is not up to date with the current project.

## Table of Contents

- [Background](#background)
- [Third Parties and APIs](#third-parties-and-apis)
- [Main](#main)
- [Clock](#clock)
- [Worldtime](#worldtime)
  - [Location](#location)
  - [Time Difference](#time-difference)
  - [Get New Timezone](#get-new-timezone)
- [Hive](#hive)
- [Loading Wrap](#loading-wrap)
- [Error Handling](#error-handling)
- [Improvement Idea](#improvement-idea)

## Background

I got an idea about this project from [Worldtime App](https://github.com/iamshaunjp/flutter-beginners-tutorial/tree/lesson-35/world_time_app) made by Shaun from [NetNinja](https://www.youtube.com/TheNetNinja) and decide to made an improvement. Another reason why this project came to fruition is because I have never worked with non-relational database services and thought this kind of project is a good example of storing non-relational data. At the time of writing this, I just learn Flutter for about a month or two and thought this project might help me learn Flutter better. Lastly I am not a native English speaker so please excuse my grammatical errors.

## Third Parties and APIs

Any dependencies that were used are:

- [Hive](https://docs.hivedb.dev/#/)
- [intl](https://pub.dev/packages/intl)
- [http](https://pub.dev/packages/http)
- [WorldTimeAPI](https://worldtimeapi.org/)

## Main

The `main.dart` contains only Hive initialization, routes, and theme settings for convenience in development. All scaffolds are provided by classes in `pages` directory.

```dart
void main() async{
  await Hive.initFlutter();
  Map<String, Widget Function(BuildContext)> routes = {
    '/clock': (context) => const ClockPage(),
    '/add_timezone': (context) => const AddTimezone()
  };

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    theme: ThemeData.dark(),
    initialRoute: '/clock',
    routes: routes,
  ));
}
```

## Clock

The clock is made from a `DateTime` class that were formatted with intl to a HH:MM:SS format. The `Clock` class contains information such as:

- clock
- day and date
- offset from UTC

```dart
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
```

In order for the clock to keeps running, a `Timer` class is needed to renew the clock in each several milliseconds. Personally I am comfortable with 100 milliseconds as intervals. The `Timer` class is used to update each `WorldTime` class.

```dart
t = Timer.periodic(const Duration(milliseconds: 100), (timer) {
  setState(() {
    clock.renew();
    if(worldtimes.isNotEmpty) {
      for (var worldtime in worldtimes.values) {
        worldtime.renew();
      }
    }
  });
});
```

![Clock_1](https://github.com/Nopalev/clock-hive/assets/86661387/71f677cc-dd2c-4545-87a0-b26610a8f0a8)

Note:
> This gif shows an earlier version of this project.

## Worldtime

The worldtime is a `DateTime` class instantiated in UTC time and has been modified according to its timezone. In order to instantiate a `WorldTime` class, an API endpoint provided by [WorldTimeAPI](https://worldtimeapi.org/) is required (see <https://worldtimeapi.org/api/timezone> for list of available timezones). Inside the class, call into API will be made in the `getTime()` method.

```dart
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
}
```

After instantiation, calling the `getTime()` method is required in order for the clock to appears. In this block of code, there is an error catching that will be explained in another section.

```dart
if(timezones.isNotEmpty) {
  for (var timezone in timezones) {
    WorldTime instance = WorldTime(url: timezone);
    await instance.getTime().catchError((error, stackTrace) {
      this.error = true;
    });
    if(!error) {
      instance.difference(clock.now);
      worldtimes[timezone] = instance;
    }
    else{
      error = false;
    }
  }
}
```

All `WorldTime` instances are stored in a `Map` with timezone as key and instance as value. Note that `Map` in dart is unordered. Each of `WorldTime` instances will be displayed using `ListTile` class generated by `ListView.builder`.

```dart
Expanded(
  child: ListView.builder(
    itemCount: worldtimes.length,
    itemBuilder: (context, index){
      return Center(
        child: ListTile(
          leading: (worldtimes.values.elementAt(index).dayTime!) ?
            const Icon(Icons.sunny) :
            const Icon(Icons.mode_night),
          title: Text(
            worldtimes.values.elementAt(index).formatted(),
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w400
            ),
            textAlign: TextAlign.center,
          ),
          subtitle: Column(
            children: [
              Text(
                '${worldtimes.values.elementAt(index).timezone()}, ${worldtimes.values.elementAt(index).date()}',
                style: const TextStyle(
                    fontSize: 12
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                worldtimes.values.elementAt(index).timeDifference.toString(),
                style: const TextStyle(
                    fontSize: 12
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              loadingWrap(() async {
                String key = worldtimes.keys.elementAt(index);
                worldtimes.remove(key);
                await box!.put(keyName, List<String>.from(worldtimes.keys));
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ),
      );
    }
  )
)
```

![Clock_Page_1](https://github.com/Nopalev/clock-hive/assets/86661387/56a2f9c5-cefb-43be-af97-2be8d881519c)

Note 1:
> This gif shows the latest version of the project.

Note 2:
> There are 2 `FloatingActionButton` for deleting all instances and create one respectively.

Each `ListTile` contains:

- An icon to indicate if it is day time or not (if the clock is between 06.00 to 18.00 it is considered day time).
- The clock in a H:mm with AM PM format.
- Timezone name or location of the instances.
- Date in each instances.
- Time different according to local time.
- a delete button.

### Location

The location for each timezones may be provided by the URL parameter itself. If the first API parameter after timezone is an area name, the last parameter must be a city name. Some cities have more than one word in their name (such as New York, Los Angeles), thus changing underscore to a space is needed.

```dart
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
```

### Time Difference

Time difference for each instances is achieved by acquiring time difference between local time and timezone time manually in minutes before create an instance of `Duration` with acquired difference. Yes, `DateTime.Difference()` method is exist. However, since the timezone clock is instantiated in UTC time, using that method would results in time difference between timezone time and UTC instead.

```dart
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
```

In order for `timeDifference` property to be used, method `difference()` must be called after the call of method `getTime()`.

### Get New Timezone

A tap on the `FloatingActionButton` with a plus sign will navigate to `add_timezone` page. The page will call `getTimezones()` method to get timezones in `List<String>` data type.

```dart
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
```

In the `add_timezone` page, if an error is caught, user will be redirected back to homepage. If the process of getting timezones is successful, 2 lists are used, one for showing suggested timezones and one for storing all available timezones.

```dart
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
```

Timezones suggestions would be based on what user type on the `TextField` class. If a user type on the `TextField` class, the `String` typed would be used to filter out all available timezones and only timezones name that has the typed `String` as a substring would be shown. Timezones also displayed using `ListTile` build by `ListView.Builder` similar to how `WorldTime` instances is being displayed.

```dart
TextField(
  onChanged: searchTimezone,
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20)
    ),
    prefixIcon: const Icon(Icons.search)
  ),
),
```

```dart
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
```

The use of 2 lists would prevent timezones loss in case of user mistyped their intended timezone.

![Add_Timezone](https://github.com/Nopalev/clock-hive/assets/86661387/ee01b8fc-24bf-4ebf-ba43-2483c87372f5)

Upon tapping a `ListTile`, timezone contained by tapped `ListTile` will be returned back to home page and a new instance of `WorldTime` will be created.

```dart
dynamic result = await Navigator.pushNamed(context, '/add_timezone');
if(result != null){
  loadingWrap(() async {
    String url = result['url'];
    WorldTime instance =  WorldTime(url: url);
    await instance.getTime().catchError((error, stackTrace) {
      this.error = true;
    });
    if(!error){
      instance.difference(clock.now);
      worldtimes[url] = instance;
      await box!.put(keyName, List<String>.from(worldtimes.keys));
    }
    else{
      error = false;
    }
  });
}
```

## Hive

Hive is used as a database service to store timezones in a form of `List<String>`. At the initialization of home page, a `List<String>` containing timezones URI is retrieved from an already opened Hive box.

```dart
box = await Hive.openBox(boxName);
List<String> timezones = List<String>.from(await box!.get(keyName, defaultValue: []));
```

Every time a `WorldTime` is instantiated or removed, the box containing instantiated timezones would be updated.

```dart
IconButton(
  onPressed: () {
    loadingWrap(() async {
      String key = worldtimes.keys.elementAt(index);
      worldtimes.remove(key);
      await box!.put(keyName, List<String>.from(worldtimes.keys));
    });
  },
  icon: const Icon(Icons.delete),
),
```

The box would be closed before the disposal of the home page.

```dart
void boxClose() async{
  await box!.close();
}

@override
void dispose() {
  boxClose();
  super.dispose();
}
```

## Loading Wrap

Since a lot of methods used were asynchronous, it is a good idea to show a loading page during the use of asynchronous method. The idea is to wrap any part of the code that are asynchronous with `setState()` method that update any properties related to loading.

```dart
void loadingWrap(void Function() func){
  setState(() {
    isLoading = true;
  });
  func();
  setState(() {
    isLoading = false;
  });
}
```

```dart
body: Center(
  child: (isLoading) ?
  const CircularProgressIndicator() :
  Column(
    children: <Widget> []
  )
);
```

Here is one example of the use of loading wrap.

```dart
loadingWrap(() async {
  worldtimes.clear();
  await box!.clear();
});
```

> To be honest, the term of loading wrap is a term that I made it up since I do not know what the professional term to describe this thing.

## Error Handling

The problem with loading wrap is if a hit to an API is failed, the state of `isLoading` will always be true forever. The use of `Future.error()` method would make catching errors in another class possible. Any method that has a Try and Catch block with the use of `Future.error()` upon catching error will enable new method called `catchError()` that allows catching errors when mentioned method is being used. Here is an example:

```dart
try{
  Response response = await get(Uri.parse('https://worldtimeapi.org/api/timezone'));
  List<String> data = List<String>.from(jsonDecode(response.body));
  return data;
}
catch(e){
  return Future.error(e);
}
```

```dart
timezones = await getTimezones().catchError((error, stackTrace) {
  return List<String>.from([]);
});
if(timezones!.isEmpty && mounted){
  Navigator.pop(context, 'error');
}
```

In this example, if an error is caught during an API hit to acquire available timezones, user would redirected back to home page. Another use of error handling in this project is during method `getTime()` in `WorldTime` class. If the API hit is failed, the instance would be discarded instead.

If an error has been caught, an instance of `AlertDialog` could be utilized to inform user if there is an error that has been occurred while still allows for the page behind to build and run at the same time.

```dart
void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // disables popup to close if tapped outside popup (need a button to close)
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'An Error Has Occurred',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 36
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(
              fontSize: 24
          ),
          textAlign: TextAlign.center,
        ),
        //buttons?
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.close
            ),
            onPressed: () { Navigator.of(context).pop(); },
            color: Colors.purple,//closes popup
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    }
  );
  setState(() {
    error = false;
  });
}
```

In `showErrorDialog()` method, an instance of `AlertDialog` will be built upon method call. And since the method is used to show an information about an occurred error, property error in the home page will set back to `false`. This is one example of how the method is utilized.

```dart
else if (result == 'error'){
  error = true;
  errorMessage = 'Failed to fetch timezones';
  if(context.mounted) {
    showErrorDialog(context);
  }
}
```

However, please note that if an error is being caught by another class, please use any way other than checking if result from a `Navigator` method is `null` or not since pressing back button will send null to the previous page.

![Error_Dialog](https://github.com/Nopalev/clock-hive/assets/86661387/b768aa6c-913b-4e1f-9ee9-4aeaeb63813f)

> I do not know if there are better way to catch errors other than this one.

## Improvement Idea

I have a plan to add several features such as:

- alarm
- stopwatch
- timer
