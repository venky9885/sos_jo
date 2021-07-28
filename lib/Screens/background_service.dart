/*import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackGroundService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BackGroundServiceState();
  }
}

class BackGroundServiceState extends State<BackGroundService> {
  int START_SERVICE = 0;
  Future<void> startService() async {
    if (Platform.isAndroid) {
      var methodChannel = MethodChannel("com.example.messages");
      String data = await methodChannel.invokeMethod("startService");
      debugPrint(data);
    }
  }

  Future<void> stopService() async {
    if (Platform.isAndroid) {
      var methodChannel = MethodChannel("com.example.messages");
      String data = await methodChannel.invokeMethod("stopService");
      debugPrint(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Background Service"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: MaterialButton(
          onPressed: () {
            if (START_SERVICE == 0) {
              startService();
              setState(() {
                START_SERVICE = 1;
              });
            } else {
              stopService();
              setState(() {
                START_SERVICE = 0;
              });
            }
          },
          color: Colors.brown,
          child: Text(
            (START_SERVICE == 0) ? "Start Service" : "Stop Service",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
*/