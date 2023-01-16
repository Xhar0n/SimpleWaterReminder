import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int hourpart = 1;

  int _weight = 61;
  int _workout = 1;
  int _wakeup = 6;
  int _bed = 10;
  int _glass = 300;

  final int _weightchange = 1;
  final int _workoutchange = 1;
  final int _glasschange = 50;
  String _wakeupshow = '';
  String _bedshow = '';

  double _totalwater = 0;
  List<String> _drink = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _changeWeight(bool plus) {
    setState(() {
      if (plus) {
        _weight += _weightchange;
      } else {
        if (_weight == 0) return;
        _weight -= _weightchange;
      }

      _saveSetting('weight', _weight);
    });
  }

  void _changeWorkout(bool plus) {
    setState(() {
      if (plus) {
        if (_workout == 48) return;
        _workout += _workoutchange;
      } else {
        if (_workout == 0) return;
        _workout -= _workoutchange;
      }

      _saveSetting('workout', _workout);
    });
  }

  void _changeWakeup(bool plus) {
    setState(() {
      if (plus) {
        if (_wakeup == hourpart * 24 - 1) _wakeup = -1;
        _wakeup += 1;
      } else {
        if (_wakeup == 0) _wakeup = hourpart * 24;
        _wakeup -= 1;
      }

      _wakeupshow = showTime(_wakeup);

      _saveSetting('wakeup', _wakeup);
    });
  }

  void _changeBed(bool plus) {
    setState(() {
      if (plus) {
        if (_bed == hourpart * 24 - 1) _bed = -1;
        _bed += 1;
      } else {
        if (_bed == 0) _bed = hourpart * 24;
        _bed -= 1;
      }

      _bedshow = showTime(_bed);

      _saveSetting('bed', _bed);
    });
  }

  void _changeGlass(bool plus) {
    setState(() {
      if (plus) {
        _glass += _glasschange;
      } else {
        if (_glass == _glasschange) return;
        _glass -= _glasschange;
      }

      _saveSetting('glass', _glass);
    });
  }

  String showTime(int ticks) {
    String time;

    int hours = ticks ~/ hourpart;
    double mins = ticks % hourpart * (60 / hourpart);

    if (ticks < hourpart * 10) {
      time = '0$hours:';
    } else {
      time = '$hours:';
    }

    if (ticks % hourpart == 0) {
      time += '0${mins.toInt()}';
    } else {
      time += '${mins.toInt()}';
    }

    return time;
  }

  double getTotalWater() {
    return _weight * 43.68 + _workout * 354.88;
  }

  List<String> getDrinkingTime() {
    double start = _wakeup.toDouble() * 60;
    int hours = _bed - _wakeup;

    if (_bed < _wakeup) hours += hourpart * 24;

    double times = _totalwater / _glass;
    double every = (hours.toDouble() * 60 / hourpart) / times;

    // print('wake: ${_wakeup / hourpart}, bed: ${_bed / hourpart}');
    // print('toatl: ${_totalwater}ml, glass: ${_glass}ml');

    if ((times % 1) != 0) times += 1;

    List<String> notitimes = [];
    for (var i = 1; i < times.toInt() + 1; i++) {
      var h = start ~/ 60;
      var m = (((start / 60) % 1) * 60).toInt();

      // print('${i}.\t${h}:${m}');

      notitimes.add('$h $m');
      start += every;
    }
    return notitimes;
  }

  Future<void> _saveSetting(String name, int value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt(name, value);

      _totalwater = getTotalWater();
      prefs.setDouble('totalwater', _totalwater);

      _drink = getDrinkingTime();
      prefs.setStringList('drink', _drink);
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weight = (prefs.getInt('weight') ?? _weight);
      _workout = (prefs.getInt('workout') ?? _workout);
      _wakeup = (prefs.getInt('wakeup') ?? _wakeup);
      _bed = (prefs.getInt('bed') ?? _bed);
      _glass = (prefs.getInt('glass') ?? _glass);

      _wakeupshow = showTime(_wakeup);
      _bedshow = showTime(_bed);

      _totalwater = (prefs.getDouble('totalwater') ?? getTotalWater());
      _drink = (prefs.getStringList('drink') ?? getDrinkingTime());

      if (prefs.getInt('_weight') == null) {
        prefs.setInt('weight', _weight);
        prefs.setInt('workout', _workout);
        prefs.setInt('wakeup', _wakeup);
        prefs.setInt('bed', _bed);
        prefs.setInt('glass', _glass);
        prefs.setDouble('totalwater', _totalwater);
        prefs.setStringList('drink', _drink);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: const Color(0xff353941),
        body: Stack(children: [
          // TOP NAV
          Positioned(
            bottom: size.height - 100,
            left: 0,
            child: Container(
              width: size.width,
              height: 120,
              child: Stack(children: [
                CustomPaint(
                  size: Size(size.width, 80),
                  painter: TopNav(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 37),
                  child: const Center(
                      child: Text('SETTINGS',
                          style: TextStyle(
                              color: Color(0xff90b8f8),
                              fontSize: 37,
                              fontFamily: 'AgencyFB'))),
                ),
              ]),
            ),
          ),

          //BOTTOM NAV
          Positioned(
            bottom: 0,
            left: 0,
            child: Stack(children: [
              CustomPaint(
                size: Size(size.width, 80),
                painter: BottomNav(),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 12, left: 50),
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                      color: Color(0xff353941), shape: BoxShape.circle),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      icon: Image.asset(
                        'assets/icons/arrow_left.png',
                        color: const Color(0xff5f85db),
                        width: 30,
                      ))),
            ]),
          ),

          //SETTINGS BOX 1
          Positioned(
            top: size.height * 0.15,
            left: size.width * 0.05,
            child: Stack(children: [
              CustomPaint(
                size: Size(size.width * 0.9, 235),
                painter: SettingsBox(),
              ),

              // WEIGHT
              Stack(children: [
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 20),
                  child: const Text('Weight',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 57),
                  child: Text('${_weight}Kg',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 37,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  width: size.width * 0.9,

                  // decoration: BoxDecoration(
                  // border: Border.all(color: Colors.red, width: 0)),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWeight(false),
                              icon: Image.asset('assets/icons/minus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                      Container(
                        width: size.width * 0.3,
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWeight(true),
                              icon: Image.asset('assets/icons/plus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                    ],
                  ),
                ),
              ]),

              // 30 MINUTES OF WORKOUT
              Stack(children: [
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 120),
                  child: const Text('30 minutes of workout',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 157),
                  child: Text('${_workout * 30} min',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 37,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 150),
                  width: size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWorkout(false),
                              icon: Image.asset('assets/icons/minus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                      Container(
                        width: size.width * 0.3,
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWorkout(true),
                              icon: Image.asset('assets/icons/plus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                    ],
                  ),
                ),
              ])
            ]),
          ),

          //SETTINGS BOX 2
          Positioned(
            top: size.height * 0.45,
            left: size.width * 0.05,
            child: Stack(children: [
              CustomPaint(
                size: Size(size.width * 0.9, 330),
                painter: SettingsBox(),
              ),

              // WAKE UP
              Stack(children: [
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 20),
                  child: const Text('Wake Up Time',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 57),
                  child: Text(_wakeupshow,
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 37,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  width: size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWakeup(false),
                              icon: Image.asset('assets/icons/minus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                      Container(
                        width: size.width * 0.3,
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWakeup(true),
                              icon: Image.asset('assets/icons/plus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                    ],
                  ),
                ),
              ]),

              // BED TIME
              Stack(children: [
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 120),
                  child: const Text('Bad Time',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 157),
                  child: Text(_bedshow,
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 37,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 150),
                  width: size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeBed(false),
                              icon: Image.asset('assets/icons/minus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                      Container(
                        width: size.width * 0.3,
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeBed(true),
                              icon: Image.asset('assets/icons/plus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                    ],
                  ),
                ),
              ]),

              // GLASS VOLUME
              Stack(children: [
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 220),
                  child: const Text('Glass Volume',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.9,
                  margin: const EdgeInsets.only(top: 257),
                  child: Text('${_glass}ml',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 37,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 250),
                  width: size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeGlass(false),
                              icon: Image.asset('assets/icons/minus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                      Container(
                        width: size.width * 0.3,
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeGlass(true),
                              icon: Image.asset('assets/icons/plus_small.png',
                                  color: const Color(0xff5f85db), width: 30))),
                    ],
                  ),
                ),
              ])
            ]),
          ),

          // TESTING
          Positioned(
              bottom: size.height * 0.02,
              right: 30,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.restart_alt)),
                  Text('${_totalwater.roundToDouble()}ml',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 30,
                          fontFamily: 'AgencyFB'),
                      textAlign: TextAlign.center),
                ],
              )),
        ]));
  }
}

class TopNav extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    Paint paint = Paint()
      ..color = const Color(0xff26282b)
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 0);

    path.lineTo(width, 0);
    path.lineTo(width, 80);

    path.arcToPoint(Offset(width - 80, 80),
        radius: const Radius.circular(10), clockwise: true);

    path.lineTo(width - 40, 120);

    path.lineTo(40, 120);
    path.lineTo(80, 80);

    path.arcToPoint(const Offset(0, 80),
        radius: const Radius.circular(10), clockwise: true);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BottomNav extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    Paint paint = Paint()
      ..color = const Color(0xff26282b)
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, height);

    path.lineTo(width, height);
    path.lineTo(width, 40);

    path.arcToPoint(Offset(width - 80, 40),
        radius: const Radius.circular(10), clockwise: false);

    path.lineTo(width - 40, 0);

    path.lineTo(40, 0);
    path.lineTo(80, 40);

    path.arcToPoint(const Offset(0, 40),
        radius: const Radius.circular(10), clockwise: false);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SettingsBox extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    Paint paint = Paint()
      ..color = const Color(0xff26282b)
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, height - 40);

    path.arcToPoint(Offset(80, height - 40),
        radius: const Radius.circular(10), clockwise: false);
    path.lineTo(40, height);

    path.lineTo(width - 40, height);
    path.arcToPoint(Offset(width - 40, height - 80),
        radius: const Radius.circular(10), clockwise: false);
    path.lineTo(width, height - 40);

    path.lineTo(width, 40);
    path.arcToPoint(Offset(width - 80, 40),
        radius: const Radius.circular(10), clockwise: false);
    path.lineTo(width - 40, 0);

    path.lineTo(40, 0);
    path.lineTo(80, 40);

    path.arcToPoint(const Offset(0, 40),
        radius: const Radius.circular(10), clockwise: false);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
