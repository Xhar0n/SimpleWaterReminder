import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'notifications.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  AwesomeNotifications().initialize(
    'resource://drawable/logo',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'basic',
        defaultColor: Colors.red,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notification',
        channelDescription: 'schuduled',
        locked: true,
        importance: NotificationImportance.High,
      ),
    ],
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/settings': (context) => const Settings(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
          //primarySwatch: Colors.purple,
          ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double defaultwaterheight = 100;
  late double _waterheight = defaultwaterheight;
  final double _waterhighmax = 0.80;
  int _animationduration = 0;

  int? _wakeup = 0;
  int? _bed = 0;
  int? _glass = 0;
  List<String> _drink = [];
  double _totalwater = 1;
  double _currentwaterlevel = 1;

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow Notifications'),
            content: const Text('Our app would like to send you notifications'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Don\'t Allow',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () => AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) => Navigator.pop(context)),
                child: const Text(
                  'Allow',
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    });
    _loadSettings();
  }

  // @override
  // void dispose() {
  //   AwesomeNotifications().actionSink.close();
  //   AwesomeNotifications().createdSink.close();
  //   super.dispose();
  // }

  void _incrementWaterhight(bool plus, Size size) {
    setState(() {
      if (_glass == null) return;

      if (plus) {
        _currentwaterlevel += (_glass ?? 0);

        getwaterheight(size);

        _saveSetting('waterlevel', _currentwaterlevel);
        _animationduration = 800;
        return;
      }

      // TEST BUTTONS
      _animationduration = 0;
      _waterheight = defaultwaterheight;
      _currentwaterlevel = 0;
    });
  }

  void getwaterheight(Size size) {
    double screenwater = (size.height * _waterhighmax) - defaultwaterheight;
    _waterheight =
        ((_currentwaterlevel / _totalwater) * screenwater) + defaultwaterheight;

    if (_waterheight >= size.height * _waterhighmax) {
      _waterheight = size.height * _waterhighmax;
      _currentwaterlevel = _totalwater;
    }


  }

  Future<void> _saveSetting(String name, double value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble(name, value);
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wakeup = prefs.getInt('wakeup');
      _bed = prefs.getInt('bed');
      _glass = prefs.getInt('glass');

      _totalwater = (prefs.getDouble('totalwater') ?? 0);
      _drink = (prefs.getStringList('drink') ?? []);

      _currentwaterlevel = (prefs.getDouble('waterlevel') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    getwaterheight(size);

    return Scaffold(
      backgroundColor: const Color(0xff353941),
      body: Stack(
        children: [
          //WATER
          AnimatedPositioned(
            duration: Duration(milliseconds: _animationduration),
            curve: Curves.bounceOut,
            bottom: 0.0,
            left: 0.0,
            top: size.height - _waterheight,
            right: 0.0,
            child: CustomPaint(
              // painter: Water(size.width, _waterheight),
              painter: RPSCustomPainter(size.width, _waterheight),

              //child: Text('$_waterhight'),
            ),
          ),

          // BOTTOM NAV
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size.width,
              height: 80,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(size.width, 80),
                    painter: BottomNav(),
                  ),
                  Center(
                    heightFactor: 0.2,
                    child: FloatingActionButton(
                      onPressed: () => _incrementWaterhight(true, size),
                      backgroundColor: const Color(0xff26282b),
                      elevation: 0.1,
                      child: Container(
                        height: 30,
                        child: Image.asset('assets/icons/glass_full.png',
                            color: const Color(0xff5f85db)),
                      ),
                    ),
                  ),

                  // BUTTONS BOTTOM NAV
                  Container(
                    width: size.width,
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Color(0xff353941),
                                shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/icons/chart_histogram.png',
                                  color: const Color(0xff5f85db),
                                  width: 30,
                                ))),
                        Container(width: size.width * 0.20),
                        Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Color(0xff353941),
                                shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/icons/glass_empty.png',
                                  color: const Color(0xff5f85db),
                                  width: 30,
                                ))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                Positioned(
                  top: 20,
                  child: Container(
                    width: size.width,
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Color(0xff353941),
                                shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {},
                                icon: Image.asset('assets/icons/bell_empty.png',
                                    color: const Color(0xff5f85db),
                                    width: 30))),
                        Container(width: size.width * 0.20),
                        Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Color(0xff353941),
                                shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                                icon: Image.asset(
                                    'assets/icons/settings_sliders.png',
                                    color: const Color(0xff5f85db),
                                    width: 30))),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 37),
                  child: Center(
                      child: Text(
                          '${_currentwaterlevel.toInt()}ml of ${_totalwater.toInt()}ml',
                          style: const TextStyle(
                              color: Color(0xff90b8f8),
                              fontSize: 25,
                              fontFamily: 'AgencyFB'))),
                ),
              ]),
            ),
          ),

          // TEST BUTTONS
          Positioned(
            bottom: size.height / 2,
            right: 0,
            child: Column(
              children: [
                IconButton(
                    onPressed: () => _incrementWaterhight(false, size),
                    icon: const Icon(Icons.restart_alt)),
                IconButton(
                    onPressed: () {
                      createWaterReminderNotification(_drink);
                      print('wake: ${_drink}');
                      // pass
                    },
                    icon: const Icon(Icons.mail)),
                IconButton(
                    onPressed: () => cancelScheduledNotifications(),
                    icon: const Icon(Icons.delete_forever)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNav1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    Paint paint = Paint()
      ..color = const Color(0xff26282b)
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(height / 2, height);

    // path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    // path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    // path.arcToPoint(Offset(size.width * 0.60, 20),
    //     radius: const Radius.circular(10.0), clockwise: false);
    // path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    // path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    // path.lineTo(size.width, size.height);
    // path.lineTo(0, size.height);
    // path.close();
    //path.quadraticBezierTo(size.width * 0.0, 0, size.width * 0.1, 0);

    path.arcToPoint(Offset(height / 2, 0),
        radius: const Radius.circular(10), clockwise: true);
    path.lineTo(width * 0.38, 0);
    path.arcToPoint(Offset(width * 0.62, 0),
        radius: const Radius.circular(3), clockwise: false);
    path.lineTo(width - height / 2, 0);
    path.arcToPoint(Offset(width - height / 2, height),
        radius: const Radius.circular(10), clockwise: true);

    path.close();

    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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

    path.arcToPoint(Offset(0, 80),
        radius: const Radius.circular(10), clockwise: true);

    path.close();

    //canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class Water extends CustomPainter {
  final double _width;
  final double _rectHeight;
  Water(this._width, this._rectHeight);

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawRect(
    //   Rect.fromLTRB(0.0, 0.0, _width, _rectHeight),
    //   Paint()..color = const Color(0xFF0099FF),
    // );

    Paint paint = Paint()
      ..color = Color.fromARGB(255, 10, 68, 169)
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, _rectHeight);

    path.lineTo(0, 0);

    path.quadraticBezierTo(_width * 0.4, -50, _width, 0);
    path.lineTo(_width, _rectHeight);

    path.close();
    canvas.drawPath(path, paint);

    Paint paint2 = Paint()
      ..color = const Color(0xff5f8ad4)
      ..style = PaintingStyle.fill;
    Path path2 = Path()..moveTo(0, _rectHeight);

    path2.lineTo(0, 0);

    path2.quadraticBezierTo(_width * 0.2, 0, _width * 0.3, 20);
    path2.quadraticBezierTo(_width * 0.9, 70, _width, 0);
    path2.lineTo(_width, _rectHeight);

    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(Water oldDelegate) {
    return false;
  }
}

void noti() async {
  print(DateTime.now().millisecondsSinceEpoch.remainder(10000));
}

class BottomNav extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width, size.height * 0.4979460);
    path_0.lineTo(size.width, size.height * 0.4979460);
    path_0.cubicTo(
        size.width,
        size.height * 0.7740570,
        size.width * 0.9502036,
        size.height * 0.9980082,
        size.width * 0.8887786,
        size.height * 0.9980082);
    path_0.lineTo(size.width * 0.1112214, size.height * 0.9980082);
    path_0.cubicTo(size.width * 0.04979644, size.height * 0.9980082, 0,
        size.height * 0.7740570, 0, size.height * 0.4979460);
    path_0.lineTo(0, size.height * 0.4979460);
    path_0.cubicTo(
        0,
        size.height * 0.2218349,
        size.width * 0.04979644,
        size.height * -0.002116270,
        size.width * 0.1112214,
        size.height * -0.002116270);
    path_0.lineTo(size.width * 0.3076081, size.height * -0.002116270);
    path_0.cubicTo(
        size.width * 0.3464377,
        size.height * -0.002116270,
        size.width * 0.3821628,
        size.height * 0.08975476,
        size.width * 0.4025954,
        size.height * 0.2381427);
    path_0.cubicTo(
        size.width * 0.4234860,
        size.height * 0.3901407,
        size.width * 0.4604071,
        size.height * 0.4826341,
        size.width * 0.5001272,
        size.height * 0.4825096);
    path_0.cubicTo(
        size.width * 0.5398473,
        size.height * 0.4823852,
        size.width * 0.5767939,
        size.height * 0.3901407,
        size.width * 0.5976845,
        size.height * 0.2381427);
    path_0.cubicTo(
        size.width * 0.6180407,
        size.height * 0.08975476,
        size.width * 0.6538422,
        size.height * -0.002116270,
        size.width * 0.6926718,
        size.height * -0.002116270);
    path_0.lineTo(size.width * 0.8887786, size.height * -0.002116270);
    path_0.cubicTo(
        size.width * 0.9502036,
        size.height * -0.002116270,
        size.width,
        size.height * 0.2218349,
        size.width,
        size.height * 0.4979460);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff26282b).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}









class RPSCustomPainter extends CustomPainter {
	final double _width;
	final double _rectHeight;
	RPSCustomPainter(this._width, this._rectHeight);

  @override
  void paint(Canvas canvas, Size size) {
	print('${_width}  ${_rectHeight}');

    // Path path_0 = Path();
    // path_0.moveTo(_width*2.946523,_rectHeight*0.2817849);
    // path_0.cubicTo(_width*3.054739,_rectHeight*0.2656897,_width*3.216141,_rectHeight*0.1519465,_width*3.216141,_rectHeight*0.1519465);
    // path_0.lineTo(_width*3.216141,_rectHeight*2.873644);
    // path_0.lineTo(0,_rectHeight*2.873644);
    // path_0.lineTo(0,_rectHeight*0.1519465);
    // path_0.cubicTo(0,_rectHeight*0.1519465,_width*0.1586715,_rectHeight*0.02482101,_width*0.2664100,_rectHeight*0.003565835);
    // path_0.cubicTo(_width*0.4820809,_rectHeight*-0.03898646,_width*0.5862751,_rectHeight*0.3139473,_width*0.8024385,_rectHeight*0.2817849);
    // path_0.cubicTo(_width*0.9106470,_rectHeight*0.2656897,_width*1.072057,_rectHeight*0.1519465,_width*1.072057,_rectHeight*0.1519465);
    // path_0.cubicTo(_width*1.072057,_rectHeight*0.1519465,_width*1.230721,_rectHeight*0.02482101,_width*1.338459,_rectHeight*0.003565835);
    // path_0.cubicTo(_width*1.554130,_rectHeight*-0.03898646,_width*1.658325,_rectHeight*0.3139473,_width*1.874488,_rectHeight*0.2817849);
    // path_0.cubicTo(_width*1.982696,_rectHeight*0.2656897,_width*2.144099,_rectHeight*0.1519465,_width*2.144099,_rectHeight*0.1519465);
    // path_0.cubicTo(_width*2.144099,_rectHeight*0.1519465,_width*2.302771,_rectHeight*0.02482101,_width*2.410509,_rectHeight*0.003565835);
    // path_0.cubicTo(_width*2.626180,_rectHeight*-0.03898646,_width*2.730374,_rectHeight*0.3139473,_width*2.946530,_rectHeight*0.2817849);
    // path_0.close();

	// Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
	// paint_0_fill.color = Color(0xff90b8f8).withOpacity(1.0);
	// canvas.drawPath(path_0,paint_0_fill);

	// Path path_1 = Path();
    // path_1.moveTo(_width*0.2696185,_rectHeight*0.2817849);
    // path_1.cubicTo(_width*0.1614025,_rectHeight*0.2656757,0,_rectHeight*0.1519465,0,_rectHeight*0.1519465);
    // path_1.lineTo(0,_rectHeight*2.873644);
    // path_1.lineTo(_width*3.216141,_rectHeight*2.873644);
    // path_1.lineTo(_width*3.216141,_rectHeight*0.1519465);
    // path_1.cubicTo(_width*3.216141,_rectHeight*0.1519465,_width*3.057477,_rectHeight*0.02482101,_width*2.949738,_rectHeight*0.003565835);
    // path_1.cubicTo(_width*2.734060,_rectHeight*-0.03898646,_width*2.629866,_rectHeight*0.3139473,_width*2.413710,_rectHeight*0.2817849);
    // path_1.cubicTo(_width*2.305501,_rectHeight*0.2656897,_width*2.144092,_rectHeight*0.1519465,_width*2.144092,_rectHeight*0.1519465);
    // path_1.cubicTo(_width*2.144092,_rectHeight*0.1519465,_width*1.985427,_rectHeight*0.02482101,_width*1.877689,_rectHeight*0.003565835);
    // path_1.cubicTo(_width*1.662018,_rectHeight*-0.03898646,_width*1.557824,_rectHeight*0.3139473,_width*1.341668,_rectHeight*0.2817849);
    // path_1.cubicTo(_width*1.233452,_rectHeight*0.2656897,_width*1.072049,_rectHeight*0.1519465,_width*1.072049,_rectHeight*0.1519465);
    // path_1.cubicTo(_width*1.072049,_rectHeight*0.1519465,_width*0.9133780,_rectHeight*0.02482101,_width*0.8056395,_rectHeight*0.003565835);
    // path_1.cubicTo(_width*0.5899686,_rectHeight*-0.03898646,_width*0.4857744,_rectHeight*0.3139473,_width*0.2696185,_rectHeight*0.2817849);
    // path_1.close();

	// Paint paint_1_fill = Paint()..style=PaintingStyle.fill;
	// paint_1_fill.color = Color(0xff5f85db).withOpacity(1.0);
	// canvas.drawPath(path_1,paint_1_fill);

	Path path_0 = Path();
    path_0.moveTo(size.width,size.height*0.06889538);
    path_0.cubicTo(size.width*0.9434632,size.height*0.08055961,size.width*0.8642655,size.height*0.09485645,size.width*0.8024310,size.height*0.09805839);
    path_0.cubicTo(size.width*0.5862751,size.height*0.1092506,size.width*0.4820809,size.height*-0.01356691,size.width*0.2664100,size.height*0.001240876);
    path_0.cubicTo(size.width*0.1586715,size.height*0.008637470,0,size.height*0.05287591,0,size.height*0.05287591);
    path_0.lineTo(0,size.height);
    path_0.lineTo(size.width,size.height);
    path_0.lineTo(size.width,size.height*0.06889538);
    path_0.close();

Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
paint_0_fill.color = Color(0xff90b8f8).withOpacity(1.0);
canvas.drawPath(path_0,paint_0_fill);

Path path_1 = Path();
    path_1.moveTo(size.width*0.8056395,size.height*0.001240876);
    path_1.cubicTo(size.width*0.5899686,size.height*-0.01356691,size.width*0.4857744,size.height*0.1092506,size.width*0.2696185,size.height*0.09805839);
    path_1.cubicTo(size.width*0.1614025,size.height*0.09245255,0,size.height*0.05287591,0,size.height*0.05287591);
    path_1.lineTo(0,size.height);
    path_1.lineTo(size.width,size.height);
    path_1.lineTo(size.width,size.height*0.03461800);
    path_1.cubicTo(size.width*0.9443586,size.height*0.02150852,size.width*0.8667950,size.height*0.005440389,size.width*0.8056395,size.height*0.001240876);
    path_1.close();

Paint paint_1_fill = Paint()..style=PaintingStyle.fill;
paint_1_fill.color = Color(0xff5f85db).withOpacity(1.0);
canvas.drawPath(path_1,paint_1_fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
