import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';

import 'user_agent/io.dart' if (dart.library.html) 'user_agent/web.dart';

const MethodChannel _channel = MethodChannel('flutter_sms');

class FlutterSmsPlatform extends PlatformInterface {
  /// Constructs a FlutterSmsPlatform.
  FlutterSmsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSmsPlatform _instance = FlutterSmsPlatform();

  /// The default instance of [FlutterSmsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSmsPlatform].
  static FlutterSmsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterSmsPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FlutterSmsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  ///
  ///
  Future<String> sendSMS({
    required String message,
    required List<String> recipients,
    bool sendDirect = false,
  }) {
    final mapData = <dynamic, dynamic>{};
    mapData['message'] = message;
    if (!kIsWeb && Platform.isIOS) {
      mapData['recipients'] = recipients;
      return _channel
          .invokeMethod<String>('sendSMS', mapData)
          .then((value) => value ?? 'Error sending sms');
    } else {
      String _phones = recipients.join(';');
      mapData['recipients'] = _phones;
      mapData['sendDirect'] = sendDirect;
      return _channel
          .invokeMethod<String>('sendSMS', mapData)
          .then((value) => value ?? 'Error sending sms');
    }
  }

  Future<bool> canSendSMS() {
    return _channel
        .invokeMethod<bool>('canSendSMS')
        .then((value) => value ?? false);
  }

  Future<bool> launchSmsMulti(List<String> numbers, [String? body]) {
    if (numbers.length == 1) {
      return launchSms(numbers.first, body);
    }
    String _phones = numbers.join(';');
    if (body != null) {
      final _body = Uri.encodeComponent(body);
      return launch('sms:/open?addresses=$_phones${separator}body=$_body');
    }
    return launch('sms:/open?addresses=$_phones');
  }

  Future<bool> launchSms(String? number, [String? body]) {
    // ignore: parameter_assignments
    number ??= '';
    if (body != null) {
      final _body = Uri.encodeComponent(body);
      return launch('sms:/$number${separator}body=$_body');
    }
    return launch('sms:/$number');
  }

  String get separator => isCupertino() ? '&' : '?';
}
