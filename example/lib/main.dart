import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    //Init Data
  }

  void _sendSMS(String message, List<String> recipents) {
    print("SMS: $message => ${recipents.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: RaisedButton(
            child: Text('Send SMS'),
            onPressed: () {
              _sendSMS("Test", ["5551231234", "5551581234", "5551301234"]);
            },
          ),
        ),
      ),
    );
  }
}
