import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_sms/flutter_sms.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

// The existing imports
// !! Keep your existing impots here !!

/// main is entry point of Flutter application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) _setTargetPlatformForDesktop();
  return runApp(MyApp());
}

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _controllerPeople, _controllerMessage;
  String _message, body;
  String _canSendSMSMessage = "Check is not run.";
  List<String> people = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _controllerPeople = TextEditingController();
    _controllerMessage = TextEditingController();
  }

  void _sendSMS(List<String> recipents) async {
    try {
      String _result = await sendSMS(
          message: _controllerMessage.text, recipients: recipents);
      setState(() => _message = _result);
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  void _canSendSMS() async {
    bool _result = await canSendSMS();
    setState(() => _canSendSMSMessage =
        _result ? 'This unit can send SMS' : 'This unit cannot send SMS');
  }

  Widget _phoneTile(String name) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(color: Colors.grey[300]),
            top: BorderSide(color: Colors.grey[300]),
            left: BorderSide(color: Colors.grey[300]),
            right: BorderSide(color: Colors.grey[300]),
          )),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => setState(() => people.remove(name)),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    name,
                    textScaleFactor: 1.0,
                    style: TextStyle(fontSize: 12.0),
                  ),
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS/MMS Example'),
        ),
        body: ListView(
          children: <Widget>[
            people == null || people.isEmpty
                ? Container(
                    height: 0.0,
                  )
                : Container(
                    height: 90.0,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            List<Widget>.generate(people.length, (int index) {
                          return _phoneTile(people[index]);
                        }),
                      ),
                    ),
                  ),
            ListTile(
              leading: Icon(Icons.people),
              title: TextField(
                controller: _controllerPeople,
                decoration: InputDecoration(labelText: "Add Phone Number"),
                keyboardType: TextInputType.number,
                onChanged: (String value) => setState(() {}),
              ),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: _controllerPeople.text.isEmpty
                    ? null
                    : () => setState(() {
                          people.add(_controllerPeople.text.toString());
                          _controllerPeople.clear();
                        }),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.message),
              title: TextField(
                decoration: InputDecoration(labelText: " Add Message"),
                controller: _controllerMessage,
                onChanged: (String value) => setState(() {}),
              ),
            ),
            Divider(),
            ListTile(
              title: Text("Can send SMS"),
              subtitle: Text(_canSendSMSMessage),
              trailing: IconButton(
                padding: EdgeInsets.symmetric(vertical: 16),
                icon: Icon(Icons.check),
                onPressed: () {
                  _canSendSMS();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Theme.of(context).accentColor),
                  padding: MaterialStateProperty.resolveWith(
                      (states) => EdgeInsets.symmetric(vertical: 16)),
                ),
                child: Text("SEND",
                    style: Theme.of(context).accentTextTheme.button),
                onPressed: () {
                  _send();
                },
              ),
            ),
            Visibility(
              visible: _message != null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _message ?? "No Data",
                        maxLines: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    if (people == null || people.isEmpty) {
      setState(() => _message = "At Least 1 Person or Message Required");
    } else {
      _sendSMS(people);
    }
  }
}
