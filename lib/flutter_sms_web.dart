import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:html' as html;

import 'flutter_sms_platform.dart';

class FlutterSmsPlugin extends FlutterSmsPlatform {
  static void registerWith(Registrar registrar) {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterSmsPlatform.instance = FlutterSmsPlugin();
  }

  @override
  Future<String> sendSMS({
    @required String message,
    @required List<String> recipients,
  }) async {
    String _phones = recipients.join(",");
    String _url =
        'sms:/open?addresses=$_phones&body=${Uri.encodeComponent(message)}';
    return "SMS Sent: " + (await launch(_url)).toString();
  }

  @override
  Future<bool> canSendSMS() {
    return canLaunch("sms:");
  }

  static var iDevices = [
    'iPad Simulator',
    'iPhone Simulator',
    'iPod Simulator',
    'iPad',
    'iPhone',
    'iPod'
  ];

  bool isCupertino() {
    bool isApple = true;
    for (var device in iDevices) {
      if (html.window.navigator.userAgent.contains(device)) {
        isApple = true;
      }
    }
    return isApple;
  }
}
