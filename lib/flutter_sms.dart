import 'dart:async';

import 'package:flutter/foundation.dart';

import 'src/flutter_sms_platform.dart';

/// Open SMS Dialog on iOS/Android/Web
Future<String> sendSMS({
  @required String message,
  @required List<String> recipients,
}) =>
    FlutterSmsPlatform.instance
        .sendSMS(message: message, recipients: recipients);

/// Launch SMS Url Scheme on all platforms
Future<bool> launchSms({
  @required String message,
  @required String number,
}) =>
    FlutterSmsPlatform.instance.launchSms(number, message);

/// Launch SMS Url Scheme on all platforms
Future<bool> launchSmsMulti({
  @required String message,
  @required List<String> numbers,
}) =>
    FlutterSmsPlatform.instance.launchSmsMulti(numbers, message);

/// Check if you can send SMS on this platform
Future<bool> canSendSMS() => FlutterSmsPlatform.instance.canSendSMS();
