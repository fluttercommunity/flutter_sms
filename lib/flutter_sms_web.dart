import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'flutter_sms.dart';
import 'src/flutter_sms_platform.dart';

class FlutterSmsPlugin extends FlutterSmsPlatform {
  static void registerWith(Registrar registrar) {
    // WidgetsFlutterBinding.ensureInitialized();
    FlutterSmsPlatform.instance = FlutterSmsPlugin();
  }

  @override
  Future<SendSMSResult> sendSMS({
    required String message,
    required List<String> recipients,
    bool sendDirect = false,
  }) async {
    bool _messageSent =
        await FlutterSmsPlatform.instance.launchSmsMulti(recipients, message);
    if (_messageSent) return SendSMSResult.sent;
    return SendSMSResult.unknownError;
  }

  @override
  Future<bool> canSendSMS() => Future.value(true);
}
