import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int hourpart = 1;

  int _workout = 1;
  int _wakeup = 6;
  int _bed = 10;
  int _glass = 300;
  // new
  int _weight = 61;
  int _height = 175;
  int _age = 18;
  int _gender = 0;
  int _activity = 0;

  final int _workoutchange = 1;
  final int _glasschange = 50;
  String _wakeupshow = '';
  String _bedshow = '';
  // new 
  final int _weightchange = 1;
  final int _heightchange = 1;
  final int _agetchange = 1;
  final int _activitytchange = 1;


  double _totalwater = 0;
  List<String> _drink = [];

  //new
  final List<int> _gendercolors = [0xff353941, 0xff5f85db, 0xff353941];
  final List<String> _activitynames = ['Sedentary', 'Light', 'Moderate', 'High', 'Extreme'];

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
    double k;
    if(_age >= 14){
      k = ((_gender == 1) ? 2 : 1.8);
    }
    else{
      k = ((_gender == 1) ? 1.885 : 1.69);
    }

    return 0.5*k * (_height*7.9 + (_weight*9.5 )) * 0.8;
  }

  List<String> getDrinkingTime() {
    double start = _wakeup.toDouble() * 60;
    int hours = _bed - _wakeup;

    if (_bed < _wakeup) hours += hourpart * 24;

    double times = _totalwater / _glass;
    double every = (hours.toDouble() * 60 / hourpart) / times;

    if ((times % 1) != 0) times += 1;

    List<String> notitimes = [];
    for (var i = 1; i < times.toInt() + 1; i++) {
      var h = start ~/ 60;
      var m = (((start / 60) % 1) * 60).toInt();

      notitimes.add('$h $m');
      start += every;
    }
    return notitimes;
  }

  //new
  void _changeHeight(bool plus) {
    setState(() {
      if (plus) {
        _height += _weightchange;
      } else {
        if (_height == 0) return;
        _height -= _heightchange;
      }

      _saveSetting('height', _height);
    });
  }
  
  void _changeGender(bool plus) {
    setState(() {
      if (plus) {
        _gender = 1;
      } else {
        _gender = 0;
      }

      _saveSetting('gender', _gender);
    });
  }

  void _changeAge(bool plus) {
    setState(() {
      if (plus) {
        if (_age == 120) return;
        _age += _agetchange;
      } else {
        if (_age == 3) return;
        _age -= _agetchange;
      }

      _saveSetting('age', _age);
    });
  }

  void _changeActivity(bool plus) {
    setState(() {
      if (plus) {
        if (_activity == 4) return;
        _activity += _activitytchange;
      } else {
        if (_activity == 0) return;
        _activity -= _activitytchange;
      }

      _saveSetting('activity', _activity);
    });
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
      // new
      _height = (prefs.getInt('height') ?? _height);
      _gender = (prefs.getInt('gender') ?? _gender);
      _age = (prefs.getInt('age') ?? _age);
      _activity = (prefs.getInt('activity') ?? _activity);
      // new end

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
        // new
        prefs.setInt('height', _height);
        prefs.setInt('gender', _gender);
        prefs.setInt('age', _age);
        prefs.setInt('activity', _activity);

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
                              fontFamily: 'AgencyFB',
                              fontWeight: FontWeight.bold,))),
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
                        'assets/icons/Left_Arrow.png',
                        color: const Color(0xff5f85db),
                        width: 30,
                      ))),
            ]),
          ),



          //SETTINGS BOX 1
          Positioned(
            top: size.height * 0.18,
            left: size.width * 0.075,
            child: Stack(children: [
              CustomPaint(
                size: Size(size.width * 0.85, 500),
                painter: SettingsBox(),
              ),

              // GENDER
              Stack(children: [
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 30),
                  child: const Text('GENDER',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 25,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                          textAlign: TextAlign.center),
                ),
                
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  width: size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Color(_gendercolors[_gender+1]), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeGender(false),
                              icon: Image.asset('assets/icons/mars.png',
                                  color: Color(_gendercolors[_gender]), width: 40))),
                      Container(
                        width: 0,
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Color(_gendercolors[_gender]), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeGender(true),
                              icon: Image.asset('assets/icons/venus.png',
                                  color: Color(_gendercolors[_gender+1]), width: 30))),
                    ],
                  ),
                ),
              ]),

              // AGE
              Stack(
                children: [
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 130),
                  child: const Text('AGE',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 25,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 172),
                  child: Text('${_age}',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 160),
                  width: size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeAge(false),
                              icon: Image.asset('assets/icons/Minus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                      Container(
                        width: 0,
                      ),
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeAge(true),
                              icon: Image.asset('assets/icons/Plus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                    ],
                  ),
                ),
              ]),

              // WEIGTH
              Stack(
                children: [
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 220),
                  child: const Text('WEIGTH',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 25,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 262),
                  child: Text('${_weight} kg',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 250),
                  width: size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWeight(false),
                              icon: Image.asset('assets/icons/Minus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                      Container(
                        width: 0,
                      ),
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeWeight(true),
                              icon: Image.asset('assets/icons/Plus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                    ],
                  ),
                ),
              ]),


              // HEIGHT
              Stack(
                children: [
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 310),
                  child: const Text('HEIGHT',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 25,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 352),
                  child: Text('${_height} cm',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 340),
                  width: size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeHeight(false),
                              icon: Image.asset('assets/icons/Minus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                      Container(
                        width: 0,
                      ),
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeHeight(true),
                              icon: Image.asset('assets/icons/Plus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                    ],
                  ),
                ),
              ]),


              // ACTIVITY
              Stack(
                children: [
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 400),
                  child: const Text('ACTIVITY',
                      style: TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 25,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 442),
                  child: Text('${_activitynames[_activity]}',
                      style: const TextStyle(
                          color: Color(0xff90b8f8),
                          fontSize: 20,
                          fontFamily: 'AgencyFB',
                          fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 430),
                  width: size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeActivity(false),
                              icon: Image.asset('assets/icons/Minus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                      Container(
                        width: 0,
                      ),
                      Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              color: Color(0xff353941), shape: BoxShape.circle),
                          child: IconButton(
                              onPressed: () => _changeActivity(true),
                              icon: Image.asset('assets/icons/Plus.png',
                                  color: const Color(0xff5f85db), width: 20))),
                    ],
                  ),
                ),
              ]),




              
            ]),
          ),

          // TAG
          Positioned(
            top: size.height * 0.16,
            left: size.width * 0.5 - 75,
            child: Stack(children: [
              CustomPaint(
                size: const Size(150, 30),
                painter: Tag(),
              ),
              Container(
                width: 150,
                margin: const EdgeInsets.only(top: 0),
                child: const Center(
                  child: Text('USER',
                    style: TextStyle(
                      color: Color(0xff353941),
                      fontSize: 25,
                      fontFamily: 'AgencyFB',
                      fontWeight: FontWeight.bold,
                    )
                  )
                ),
              ),
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
          
    Path path_0 = Path();
    path_0.moveTo(size.width*0.0005257624,size.height*0.07378013);
    path_0.cubicTo(size.width*0.0005257624,size.height*0.03319483,size.width*0.05937371,size.height*0.0002939447,size.width*0.1319664,size.height*0.0002939447);
    path_0.lineTo(size.width*0.8680336,size.height*0.0002939447);
    path_0.cubicTo(size.width*0.9406267,size.height*0.0002939447,size.width*0.9994742,size.height*0.03319483,size.width*0.9994742,size.height*0.07378013);
    path_0.lineTo(size.width*0.9994742,size.height*0.2501470);
    path_0.lineTo(size.width*0.9994742,size.height*0.3750735);
    path_0.lineTo(size.width*0.9994742,size.height*0.4375367);
    path_0.lineTo(size.width*0.9994742,size.height*0.4464633);
    path_0.cubicTo(size.width*0.9994742,size.height*0.4566467,size.width*0.9835478,size.height*0.4636026,size.width*0.9679285,size.height*0.4688419);
    path_0.cubicTo(size.width*0.9516961,size.height*0.4742869,size.width*0.9395521,size.height*0.4807478,size.width*0.9363828,size.height*0.4911817);
    path_0.cubicTo(size.width*0.9354532,size.height*0.4942410,size.width*0.9353449,size.height*0.4989471,size.width*0.9353323,size.height*0.4998483);
    path_0.cubicTo(size.width*0.9353312,size.height*0.4999506,size.width*0.9353312,size.height*0.5000494,size.width*0.9353323,size.height*0.5001517);
    path_0.cubicTo(size.width*0.9353449,size.height*0.5010529,size.width*0.9354532,size.height*0.5057590,size.width*0.9363828,size.height*0.5088183);
    path_0.cubicTo(size.width*0.9395521,size.height*0.5192522,size.width*0.9516961,size.height*0.5257131,size.width*0.9679285,size.height*0.5311581);
    path_0.cubicTo(size.width*0.9835478,size.height*0.5363974,size.width*0.9994742,size.height*0.5433533,size.width*0.9994742,size.height*0.5535367);
    path_0.lineTo(size.width*0.9994742,size.height*0.5624633);
    path_0.lineTo(size.width*0.9994742,size.height*0.6249265);
    path_0.lineTo(size.width*0.9994742,size.height*0.7498530);
    path_0.lineTo(size.width*0.9994742,size.height*0.9262199);
    path_0.cubicTo(size.width*0.9994742,size.height*0.9668078,size.width*0.9406267,size.height*0.9997061,size.width*0.8680336,size.height*0.9997061);
    path_0.lineTo(size.width*0.1319664,size.height*0.9997061);
    path_0.cubicTo(size.width*0.05937371,size.height*0.9997061,size.width*0.0005257624,size.height*0.9668078,size.width*0.0005257624,size.height*0.9262199);
    path_0.lineTo(size.width*0.0005257624,size.height*0.7498530);
    path_0.lineTo(size.width*0.0005257624,size.height*0.6249265);
    path_0.lineTo(size.width*0.0005257624,size.height*0.5624633);
    path_0.lineTo(size.width*0.0005257624,size.height*0.5535367);
    path_0.cubicTo(size.width*0.0005257624,size.height*0.5433533,size.width*0.01645258,size.height*0.5363974,size.width*0.03207150,size.height*0.5311581);
    path_0.cubicTo(size.width*0.04830368,size.height*0.5257131,size.width*0.05948254,size.height*0.5191464,size.width*0.06361725,size.height*0.5088183);
    path_0.cubicTo(size.width*0.06496562,size.height*0.5054503,size.width*0.06466877,size.height*0.5034515,size.width*0.06466877,size.height*0.5000000);
    path_0.cubicTo(size.width*0.06466877,size.height*0.4965485,size.width*0.06496562,size.height*0.4945497,size.width*0.06361725,size.height*0.4911817);
    path_0.cubicTo(size.width*0.05948254,size.height*0.4808536,size.width*0.04830368,size.height*0.4742869,size.width*0.03207150,size.height*0.4688419);
    path_0.cubicTo(size.width*0.01645258,size.height*0.4636026,size.width*0.0005257624,size.height*0.4566467,size.width*0.0005257624,size.height*0.4464633);
    path_0.lineTo(size.width*0.0005257624,size.height*0.4375367);
    path_0.lineTo(size.width*0.0005257624,size.height*0.3750735);
    path_0.lineTo(size.width*0.0005257624,size.height*0.2501470);
    path_0.lineTo(size.width*0.0005257624,size.height*0.07378013);
    path_0.close();

    Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
    paint_0_fill.color = Color(0xff26282B).withOpacity(1.0);
    canvas.drawPath(path_0,paint_0_fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
      return true;
  }
}

class Tag extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
          
    Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
    paint_0_fill.color = Color(0xff5F85DB).withOpacity(1.0);
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(size.width*0.0009980040,size.height*0.004950495,size.width*0.9980040,size.height*0.9900990),bottomRight: Radius.circular(size.width*0.09980040),bottomLeft:  Radius.circular(size.width*0.09980040),topLeft:  Radius.circular(size.width*0.09980040),topRight:  Radius.circular(size.width*0.09980040)),paint_0_fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}