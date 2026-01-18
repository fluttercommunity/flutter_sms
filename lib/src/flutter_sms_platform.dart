import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';

// Assuming 'user_agent/io.dart' and 'user_agent/web.dart' are part of your plugin
// and handle user agent sniffing if needed for web.

const MethodChannel _channel = MethodChannel('flutter_sms');

class FlutterSmsPlatform extends PlatformInterface {
  /// Constructs a FlutterSmsPlatform.
  FlutterSmsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSmsPlatform _instance =
      MethodChannelFlutterSms(); // Initialize with the default MethodChannel implementation

  /// The default instance of [FlutterSmsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSms].
  static FlutterSmsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterSmsPlatform] when they register themselves.
  static set instance(FlutterSmsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sends an SMS message to a list of recipients.
  ///
  /// The [message] is the body of the SMS.
  /// The [recipients] is a list of phone numbers.
  /// [sendDirect] (Android only) attempts to send the SMS directly without
  /// opening the messaging app. This might require additional permissions.
  Future<String> sendSMS({
    required String message,
    required List<String> recipients,
    bool sendDirect = false,
  }) {
    throw UnimplementedError('sendSMS() has not been implemented.');
  }

  /// Checks if the device can send SMS messages.
  Future<bool> canSendSMS() {
    throw UnimplementedError('canSendSMS() has not been implemented.');
  }

  /// Launches the default SMS application with multiple recipients and an optional body.
  ///
  /// Returns `true` if the SMS app was launched, `false` otherwise.
  Future<bool> launchSmsMulti(List<String> numbers, [String? body]) {
    throw UnimplementedError('launchSmsMulti() has not been implemented.');
  }

  /// Launches the default SMS application with a single recipient and an optional body.
  ///
  /// Returns `true` if the SMS app was launched, `false` otherwise.
  Future<bool> launchSms(String? number, [String? body]) {
    throw UnimplementedError('launchSms() has not been implemented.');
  }
}

/// An implementation of [FlutterSmsPlatform] that uses method channels.
class MethodChannelFlutterSms extends FlutterSmsPlatform {
  @override
  Future<String> sendSMS({
    required String message,
    required List<String> recipients,
    bool sendDirect = false,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'message': message,
    };

    if (!kIsWeb && Platform.isIOS) {
      arguments['recipients'] = recipients;
    } else {
      // For Android and other platforms, join recipients with ';'
      arguments['recipients'] = recipients.join(';');
      arguments['sendDirect'] = sendDirect;
    }

    try {
      final String? result =
          await _channel.invokeMethod<String>('sendSMS', arguments);
      return result ?? 'Error sending sms';
    } on PlatformException catch (e) {
      return 'Failed to send SMS: ${e.message}';
    }
  }

  @override
  Future<bool> canSendSMS() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('canSendSMS');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking SMS capability: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> launchSmsMulti(List<String> numbers, [String? body]) async {
    if (numbers.length == 1) {
      return launchSms(numbers.first, body);
    }
    final String phones = numbers.join(';');
    String uri = 'sms:/open?addresses=$phones';
    if (body != null) {
      final String encodedBody = Uri.encodeComponent(body);
      uri += '${_getSeparator()}body=$encodedBody';
    }
    return _launchUrl(uri);
  }

  @override
  Future<bool> launchSms(String? number, [String? body]) async {
    final String actualNumber = number ?? '';
    String uri = 'sms:/$actualNumber';
    if (body != null) {
      final String encodedBody = Uri.encodeComponent(body);
      uri += '${_getSeparator()}body=$encodedBody';
    }
    return _launchUrl(uri);
  }

  // Helper to determine the URL separator for SMS intents
  String _getSeparator() {
    return kIsWeb ? '&' : (Platform.isIOS ? '&' : '?');
  }

  // Helper to launch URLs using url_launcher
  Future<bool> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
      return false;
    }
  }
}
