import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/flutter_sms_platform.dart';

class FlutterSmsPlugin extends FlutterSmsPlatform {
  static void registerWith(Registrar registrar) {
    // WidgetsFlutterBinding.ensureInitialized();
    FlutterSmsPlatform.instance = FlutterSmsPlugin();
  }

  @override
  Future<String> sendSMS({
    required String message,
    required List<String> recipients,
    bool sendDirect = false,
  }) async {
    bool _messageSent =
        await FlutterSmsPlatform.instance.launchSmsMulti(recipients, message);
    if (_messageSent) return 'Message Sent!';
    return 'Error Sending Message!';
  }

  @override
  Future<bool> canSendSMS() => Future.value(true);
}
