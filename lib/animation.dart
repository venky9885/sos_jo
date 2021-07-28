import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geocoder/geocoder.dart';
import 'dart:math';

import 'package:get_storage/get_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sms/sms.dart';
import 'package:sos_jo/location.dart';

class MyCustomWidget extends StatefulWidget {
  @override
  _MyCustomWidgetState createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    controller.stop();
    controller.reset();
    controller.repeat(
      period: Duration(seconds: 1),
    );
  }

  void showToast(String msg, BuildContext ctx) {
    Alert(
      context: ctx,
      type: AlertType.success,
      title: msg.toString(),
      //desc: "Flutter is more awesome with RFlutter Alert.",
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  SmsSender sender = new SmsSender();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          painter: SpritePainter(controller),
          child: Container(
            height: 250,
            width: 250,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final box = GetStorage();
                  String d = box.read('contact');
                  Vibrate.vibrate();
                  determinePosition().then((value) async {
                    // print(value.latitude);
                    //var geocoding = AppState.of(context).mode;
                    var results = await Geocoder.local
                        .findAddressesFromCoordinates(
                            new Coordinates(value.latitude, value.longitude));
                    print(results[0].addressLine);
                    sender
                        .sendSms(new SmsMessage(d, '${results[0].addressLine}'))
                        .then((value) {
                      print(value.state);
                      value.onStateChanged.listen((event) {
                        //print(event);
                        if (event.toString() == 'SmsMessageState.Sent') {
                          print(event.toString());
                          showToast('Message Sent', context);
                        }
                      });
                    });
                    // String message =
                    //     "I am in problem in address : ${results[0].addressLine}";
                    List<String> recipents = [d];

                    //_sendSMS(message, recipents);
                  });
                },
                child: Image.asset(
                  'assets/sos.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            /*child: GestureDetector(
              onTap: () {
                final box = GetStorage();
                String d = box.read('contact');
                Vibrate.vibrate();
                determinePosition().then((value) async {
                  // print(value.latitude);
                  //var geocoding = AppState.of(context).mode;
                  var results = await Geocoder.local
                      .findAddressesFromCoordinates(
                          new Coordinates(value.latitude, value.longitude));
                  print(results[0].addressLine);
                  sender
                      .sendSms(new SmsMessage(d, '${results[0].addressLine}'))
                      .then((value) {
                    print(value.state);
                    value.onStateChanged.listen((event) {
                      //print(event);
                      if (event.toString() == 'SmsMessageState.Sent') {
                        print(event.toString());
                        showToast('Message Sent', context);
                      }
                    });
                  });
                  // String message =
                  //     "I am in problem in address : ${results[0].addressLine}";
                  List<String> recipents = [d];

                  //_sendSMS(message, recipents);
                });
              },
              child: Image.asset(
                'assets/sos.png',
                height: 150,
                width: 150,
              ),
            ),*/
          ),
        ),
      ),
    );
  }
}

class SpritePainter extends CustomPainter {
  final Animation<double> animation;

  SpritePainter(this.animation) : super(repaint: animation);

  void circle(Canvas canvas, Rect rect, double value) {
    double opacity = (1.0 - (value / 4.0)).clamp(.0, 1.0);
    Color color = Colors.pinkAccent.withOpacity(opacity);

    double size = rect.width / 3;
    double area = size * size;
    double radius = sqrt(area * value / 4);

    final Paint paint = Paint()..color = color;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + animation.value);
    }
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return true;
  }
}
