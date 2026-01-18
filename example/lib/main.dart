import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _controllerPeople, _controllerMessage;
  String? _message, body;
  String _canSendSMSMessage = 'Check is not run.';
  List<String> people = [];
  bool sendDirect = false;
  bool _isLoading = false;

  Future<void> requestSMSPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _controllerPeople.dispose();
    _controllerMessage.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    requestSMSPermission();
    _controllerPeople = TextEditingController();
    _controllerMessage = TextEditingController();
  }

  Future<void> _sendSMS(List<String> recipients) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _message = 'Sending SMS...';
    });

    try {
      developer.log('Attempting to send SMS to: ${recipients.join(", ")}');
      developer.log('Message: ${_controllerMessage.text}');
      developer.log('Send Direct: $sendDirect');

      String _result = await sendSMS(
        message: _controllerMessage.text,
        recipients: recipients,
        sendDirect: sendDirect,
      );

      developer.log('SMS Result: $_result');

      setState(() {
        _message = _result;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      developer.log('PlatformException: ${e.code} - ${e.message}');
      setState(() {
        _message = 'PlatformException: ${e.code} - ${e.message}';
        _isLoading = false;
      });
    } catch (error) {
      developer.log('Error sending SMS: $error');
      setState(() {
        _message = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  Future<bool> _canSendSMS() async {
    if (_isLoading) return false;

    setState(() {
      _isLoading = true;
      _canSendSMSMessage = 'Checking...';
    });

    try {
      developer.log('Checking if device can send SMS...');
      bool _result = await canSendSMS();
      developer.log('Can send SMS result: $_result');

      setState(() {
        _canSendSMSMessage =
            _result ? 'This unit can send SMS' : 'This unit cannot send SMS';
        _isLoading = false;
      });
      return _result;
    } on PlatformException catch (e) {
      developer
          .log('PlatformException in canSendSMS: ${e.code} - ${e.message}');
      setState(() {
        _canSendSMSMessage = 'Error checking SMS capability: ${e.message}';
        _isLoading = false;
      });
      return false;
    } catch (error) {
      developer.log('Error in canSendSMS: $error');
      setState(() {
        _canSendSMSMessage = 'Error checking SMS capability: $error';
        _isLoading = false;
      });
      return false;
    }
  }

  Widget _phoneTile(String name) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => people.remove(name)),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    name,
                    textScaler: const TextScaler.linear(1),
                    style: const TextStyle(fontSize: 12),
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: ListView(
          children: <Widget>[
            // Debug info section
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Debug Info:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Recipients: ${people.length}'),
                    Text('Message length: ${_controllerMessage.text.length}'),
                    Text('Send Direct: $sendDirect'),
                  ],
                ),
              ),
            ),
            if (people.isEmpty)
              const SizedBox(height: 0)
            else
              SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<Widget>.generate(people.length, (int index) {
                      return _phoneTile(people[index]);
                    }),
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.people),
              title: TextField(
                controller: _controllerPeople,
                decoration:
                    const InputDecoration(labelText: 'Add Phone Number'),
                keyboardType: TextInputType.phone,
                onChanged: (String value) => setState(() {}),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _controllerPeople.text.isEmpty
                    ? null
                    : () => setState(() {
                          people.add(_controllerPeople.text.toString());
                          _controllerPeople.clear();
                        }),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: TextField(
                decoration: const InputDecoration(labelText: 'Add Message'),
                controller: _controllerMessage,
                maxLines: 3,
                onChanged: (String value) => setState(() {}),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Can send SMS'),
              subtitle: Text(_canSendSMSMessage),
              trailing: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        _canSendSMS();
                      },
                    ),
            ),
            SwitchListTile(
                title: const Text('Send Direct'),
                subtitle: const Text(
                    'Should we skip the additional dialog? (Android only - requires SMS permission)'),
                value: sendDirect,
                onChanged: (bool newValue) {
                  setState(() {
                    sendDirect = newValue;
                  });
                }),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.primary),
                  padding: WidgetStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(vertical: 4)),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        _send();
                      },
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SENDING...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        'SEND',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
              ),
            ),
            Visibility(
              visible: _message != null,
              child: Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Result:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        _message ?? 'No Data',
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    if (people.isEmpty) {
      setState(() => _message = 'At least 1 phone number is required');
    } else if (_controllerMessage.text.trim().isEmpty) {
      setState(() => _message = 'Message cannot be empty');
    } else {
      _sendSMS(people);
    }
  }
}
