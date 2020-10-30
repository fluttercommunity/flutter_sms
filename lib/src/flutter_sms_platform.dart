import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

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

  Future<String> sendSMS({
    @required String message,
    @required List<String> recipients,
  }) {
    var mapData = Map<dynamic, dynamic>();
    mapData["message"] = message;
    if (!kIsWeb && Platform.isIOS) {
      mapData["recipients"] = recipients;
      return _channel.invokeMethod<String>('sendSMS', mapData);
    } else {
      String _phones = recipients.join(";");
      mapData["recipients"] = _phones;
      return _channel.invokeMethod<String>('sendSMS', mapData);
    }
  }

  Future<bool> canSendSMS() {
    return _channel.invokeMethod<bool>('canSendSMS');
  }

  Future<bool> launchSmsMulti(List<String> numbers, [String body]) {
    if (numbers == null || numbers.length == 1) {
      return launchSms(numbers?.first, body);
    }
    String _phones = numbers.join(";");
    if (body != null) {
      final _body = Uri.encodeComponent(body);
      return launch('sms:/open?addresses=$_phones${seperator}body=$_body');
    }
    return launch('sms:/open?addresses=$_phones');
  }

  Future<bool> launchSms(String number, [String body]) {
    if (number == null) {
      number = '';
    }
    if (body != null) {
      final _body = Uri.encodeComponent(body);
      return launch('sms:/$number${seperator}body=$_body');
    }
    return launch('sms:/$number');
  }

  String get seperator => isCupertino() ? '&' : '?';

  bool isCupertino() {
    if (kIsWeb) {
      final _devices = [
        'iPad Simulator',
        'iPhone Simulator',
        'iPod Simulator',
        'iPad',
        'iPhone',
        'iPod',
        'Mac OS X',
      ];
      final String _agent = FlutterUserAgent.webViewUserAgent;
      for (final device in _devices) {
        if (_agent.contains(device)) {
          return true;
        }
      }
      return false;
    }
    return Platform.isIOS || Platform.isMacOS;
  }
}
