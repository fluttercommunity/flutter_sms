import 'dart:async';

import 'package:flutter/foundation.dart';

import 'flutter_sms_platform.dart';

Future<String> sendSMS({
  @required String message,
  @required List<String> recipients,
}) =>
    FlutterSmsPlatform.instance
        .sendSMS(message: message, recipients: recipients);

Future<bool> canSendSMS() => FlutterSmsPlatform.instance.canSendSMS();
