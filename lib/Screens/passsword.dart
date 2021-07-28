import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:get_storage/get_storage.dart';

//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//android:requestLegacyExternalStorage="true"
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
    /*Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
    );*/
  }
  // void showToast(String tx) {
  //   Fluttertoast.showToast(
  //     msg: tx,
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.CENTER,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: Colors.greenAccent,
  //     textColor: Colors.white,
  //     fontSize: 20.0,
  //   );
  // }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.cyanAccent,
        appBar: CupertinoNavigationBar(
          middle: Text('Emergency Contact'),
        ),
        // AppBar(
        //   backgroundColor: Colors.cyanAccent,
        //   title: Text(
        //     'Update Credentials',
        //     style: TextStyle(
        //         color: Colors.black87,
        //         fontWeight: FontWeight.w500,
        //         fontSize: 20),
        //   ),
        // ),
        body: Form(
          key: _formKey,
          child: Padding(
              padding: EdgeInsets.all(0),
              child: Container(
                /*decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                        colors: [Color(0xFF4c41a3), Color(0xFF1f186f)])),*/
                child: ListView(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Store Contact',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        )),

                    // ),
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      color: Colors.grey[300],
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter Valid Name';
                            }
                            return null;
                          },
                          controller: passwordController,
                          // obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Contact',
                            hintText: 'Enter Number',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Card(
                          // style: NeumorphicStyle(
                          //     shape: NeumorphicShape.concave,
                          //     boxShape: NeumorphicBoxShape.roundRect(
                          //         BorderRadius.circular(26)),
                          //     depth: -10,
                          //     lightSource: LightSource.topLeft,
                          //     color: Colors.cyanAccent),
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.cyan,
                            child: Text('Update Contact'),
                            onPressed: () async {
                              if (passwordController.text.toString().length ==
                                  0) {
                                return;
                              }
                              if (_formKey.currentState.validate()) {
                                FocusScope.of(context).unfocus();
                                final box = GetStorage();
                                // final prefs =
                                //     await SharedPreferences.getInstance();
                                //print(nameController.text);
                                //String id = box.read('email');
                                print(passwordController.text);
                                //update(id, passwordController.text);

                                box.write("contact",
                                    '+91' + (passwordController.text));
                                //print(prefs.getString("email"));
                                print(box.read("password"));
                                showToast('Updated Successfully', context);
                                passwordController.clear();
                                //prefs.setString("email",nameController.text.split(" ").join(""));

                              }
                            },
                          ),
                        )),
                    // Container(
                    //     child: Row(
                    //   children: <Widget>[
                    //     Text('Does not have account?'),
                    //     FlatButton(
                    //       textColor: Colors.blue,
                    //       child: Text(
                    //         'Sign in',
                    //         style: TextStyle(fontSize: 20),
                    //       ),
                    //       onPressed: () {
                    //         //signup screen
                    //       },
                    //     )
                    //   ],
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    // ))
                  ],
                ),
              )),
        ));
  }
}
