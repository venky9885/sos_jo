//import 'dart:async';
import 'dart:async';
//import 'dart:html';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_flashlight/flutter_flashlight.dart';
//import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geocoder/geocoder.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:screen_state/screen_state.dart';
import 'package:shake/shake.dart';
import 'package:sms/sms.dart';
//import 'package:sos_jo/Screens/background_service.dart';
import 'package:sos_jo/Screens/passsword.dart';
import 'package:sos_jo/location.dart';
//import 'package:torch_compat/torch_compat.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: import_of_legacy_library_into_null_safe
//import 'package:hardware_buttons/hardware_buttons.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SmsSender sender = new SmsSender();
  String address = 'hello ';

  Screen _screen;
  StreamSubscription<ScreenStateEvent> _subscription;
  int scr = 0;
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

  void onData(ScreenStateEvent event) {
    print(event);
    if (event == ScreenStateEvent.SCREEN_OFF) {
      scr += 1;
    } else if (event == ScreenStateEvent.SCREEN_ON) {
      scr += 1;
    }
    print(scr);
    if (scr == 5) {
      final box = GetStorage();
      String d = box.read('contact');
      Vibrate.vibrate();
      determinePosition().then((value) async {
        // print(value.latitude);
        //var geocoding = AppState.of(context).mode;
        var results = await Geocoder.local.findAddressesFromCoordinates(
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
        // List<String> recipents = [d];

        // _sendSMS(message, recipents);
      });
      scr = 0;
    }
  }

  void startListening() {
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream.listen(onData);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  // void _sendSMS(String message, List<String> recipents) async {
  //   String _result = await sendSMS(message: message, recipients: recipents)
  //       .catchError((onError) {
  //     print(onError);
  //   });
  //   print(_result);
  // }

  void stopListening() {
    _subscription.cancel();
  }

  // StreamSubscription _volumeButtonSubscription;
  // AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer aud = AssetsAudioPlayer();
//create a new player
  final audioPlayer = AssetsAudioPlayer();
  bool _hasFlashlight = false;
// // possible values
// // LoopMode.none : not looping
// // LoopMode.single : looping a single audio
// // LoopMode.playlist : looping the fyll playlist
  int ct = 0;
// assetsAudioPlayer.setLoopMode(LoopMode.single);
  @override
  void initState() {
    startListening();
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      print("shaked");
      ct += 1;
      if (ct == 2) {
        final box = GetStorage();
        String d = box.read('contact');
        Vibrate.vibrate();
        determinePosition().then((value) async {
          // print(value.latitude);
          //var geocoding = AppState.of(context).mode;
          var results = await Geocoder.local.findAddressesFromCoordinates(
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
          // List<String> recipents = ["1234567890", "5556787676"];

          // _sendSMS(message, recipents);
        });
        ct = 0;
      }
      //Vibrate.vibrate();
      // Do stuff on phone shake
    });
    initFlashlight();
    //audioPlayer.setLoopMode(LoopMode.single);
    //final LoopMode loopMode = audioPlayer.setLoopMode(value);
    audioPlayer.open(Audio('assets/sounds/siren.mp3'),
        autoStart: false, showNotification: false, loopMode: LoopMode.single);
    //aud.setLoopMode(LoopMode.single);
    aud.open(Audio('assets/sounds/whistle.mp3'),
        autoStart: false, showNotification: false, loopMode: LoopMode.single);
    super.initState();
  }

  bool play = false;
  bool whistle = false;
  bool torch = false;
  initFlashlight() async {
    bool hasFlash = await Flashlight.hasFlashlight;
    print("Device has flash ? $hasFlash");
    setState(() {
      _hasFlashlight = hasFlash;
    });
  }
  // void playAudioNetwork() async{
  //   try{
  //     await player.open(
  //       Audio.network("URL PATH")
  //     );
  //   }catch(t){

  //   }
  // }
  // this will create a instance object of a class
  // @override
  // void initState() {
  //   super.initState();
  //   // lockButtonEvents.listen((LockButtonEvent event) {
  //   //   print(event);
  //   // });
  //   _volumeButtonSubscription =
  //       volumeButtonEvents.listen((VolumeButtonEvent event) {
  //     // do something
  //     // event is either VolumeButtonEvent.VOLUME_UP or VolumeButtonEvent.VOLUME_DOWN
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    stopListening();
    // be sure to cancel on dispose
    audioPlayer.dispose();

    aud.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrange,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SOS App'),
          //actions: [IconButton(onPressed: onPressed, icon: icon)],
        ),
        body: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(
                              Icons.call,
                              size: 30.0,
                              color: Colors.black,
                            ),
                            onTap: () {
                              final box = GetStorage();
                              String d = box.read('contact');
                              launch(('tel://$d'));
                              print("Pressed");
                            }),
                        Text("Call")
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final box = GetStorage();
                      String d = box.read('contact');
                      Vibrate.vibrate();
                      determinePosition().then((value) async {
                        // print(value.latitude);
                        //var geocoding = AppState.of(context).mode;
                        var results = await Geocoder.local
                            .findAddressesFromCoordinates(new Coordinates(
                                value.latitude, value.longitude));
                        print(results[0].addressLine);
                        sender
                            .sendSms(
                                new SmsMessage(d, '${results[0].addressLine}'))
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
                  ),
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(
                              Icons.contacts,
                              size: 30.0,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                              print("Pressed");
                            }),
                        Text("Contacts")
                      ],
                    ),
                  ),
                  /*Container(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(
                              Icons.car_repair,
                              size: 30.0,
                              color: Colors.black,
                            ),
                            onTap: () {
                              print("Pressed");
                            }),
                        Text("Crash Detect")
                      ],
                    ),
                  ),*/
                ],
              ),
              /*Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        determinePosition().then((value) async {
                          // print(value.latitude);
                          //var geocoding = AppState.of(context).mode;
                          var results = await Geocoder.local
                              .findAddressesFromCoordinates(new Coordinates(
                                  value.latitude, value.longitude));
                          print(results[0].addressLine);
                          String message =
                              "I am in problem in address : ${results[0].addressLine}";
                          List<String> recipents = ["1234567890", "5556787676"];

                          _sendSMS(message, recipents);
                        });
                      },
                      child: Image.asset(
                        'assets/sos.png',
                        height: 150,
                        width: 150,
                      ),
                    )
                  ],
                ),
              ),*/
              //!country start
              Container(
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'JORDAN',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'TAP TO CALL',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          )
                        ],
                      ),
                      GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6.0,
                          mainAxisSpacing: 6.0,
                          shrinkWrap: true,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launch(('tel://91125'));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/police.svg',
                                            height: 25,
                                            width: 25,
                                          ),
                                        ),
                                        // IconButton(
                                        //   onPressed: () {},
                                        //   icon: SvgPicture.asset(
                                        //       'assets/police.svg'),
                                        //   /*Icon(
                                        //       Icons.fireplace,
                                        //       color: Colors.redAccent,
                                        //     )*/
                                        // ),
                                        Text(
                                          'Police',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        Text('911'),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                launch(('tel://91125'));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                              'assets/medical.svg'),
                                        ),
                                        // IconButton(
                                        //   onPressed: () {},
                                        //   icon: SvgPicture.asset(
                                        //     'assets/medical.svg',
                                        //     color: Colors.redAccent,
                                        //   ),
                                        //   /* Icon(
                                        //       Icons.medical_services,
                                        //       color: Colors.redAccent,
                                        //     )
                                        //     */
                                        // ),
                                        Text(
                                          'Ambulance',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        Text('911'),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                launch(('tel://91125'));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                              'assets/fire.svg'),
                                        ),
                                        // IconButton(
                                        //   onPressed: () {},
                                        //   icon: SvgPicture.asset(
                                        //       'assets/fire.svg'),
                                        //   /*Icon(
                                        //       Icons.fireplace,
                                        //       color: Colors.redAccent,
                                        //     )*/
                                        // ),
                                        Text(
                                          'Fire',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        Text('911'),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]),
                    ],
                  ),
                ),
              ),
              //!red ambulance end
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PANIC',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'TAP TO TOGGLE PLAY',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  ],
                ),
              ),
              //!toggle play ends
              GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3.0,
                  mainAxisSpacing: 3.0,
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('player tapp');
                        play = !play;
                        if (play == true) {
                          audioPlayer.play();
                          //play = !play;
                        } else {
                          audioPlayer.pause();
                          // play = !play;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset(
                                  'assets/siren.svg',
                                  height: 35,
                                  width: 35,
                                ),
                                Text(
                                  'Siren',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),

                                ///Text('100'),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('toprcjh tapp');
                        torch = !torch;
                        if (torch == true) {
                          Flashlight.lightOn();
                          //TorchCompat.turnOn();
                          //play = !play;
                        } else {
                          Flashlight.lightOff();
                          //TorchCompat.turnOff();
                          // play = !play;
                        }
                      },
                      // onTap: () {
                      //   TorchCompat.turnOn();
                      //   TorchCompat.turnOff();
                      // },
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset(
                                  'assets/flash.svg',
                                  height: 35,
                                  width: 35,
                                ),

                                Text(
                                  'Flash',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                                // Text('108'),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('whistle');
                        whistle = !whistle;
                        if (whistle == true) {
                          aud.play();
                          //play = !play;
                        } else {
                          aud.pause();
                          // play = !play;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset(
                                  'assets/whistle.svg',
                                  height: 35,
                                  width: 35,
                                ),
                                Text(
                                  'Whistle',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                                // Text('101'),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    )
                  ]),
              //!seond gridview end
              //Expanded(child: ,)
            ],
          ),
        ),
      ),
    );
  }
}
