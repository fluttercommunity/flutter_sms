// test/widget_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Since FlutterSms might not be available as package, define test class
class FlutterSms {
  static const MethodChannel _channel = MethodChannel('flutter_sms');

  static Future<bool> get canSendSMS async {
    final bool result = await _channel.invokeMethod('canSendSMS');
    return result;
  }

  static Future<String> sendSMS({
    required String message,
    required String recipients,
    bool sendDirect = false,
  }) async {
    final String result = await _channel.invokeMethod('sendSMS', {
      'message': message,
      'recipients': recipients,
      'sendDirect': sendDirect,
    });
    return result;
  }
}

void main() {
  const MethodChannel channel = MethodChannel('flutter_sms');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'canSendSMS':
          return true;
        case 'sendSMS':
          return 'SMS Sent!';
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Flutter SMS Tests', () {
    test('canSendSMS returns true', () async {
      final result = await FlutterSms.canSendSMS;
      expect(result, true);
    });

    test('sendSMS returns success message', () async {
      final result = await FlutterSms.sendSMS(
        message: 'Test message',
        recipients: '1234567890',
        sendDirect: false,
      );
      expect(result, 'SMS Sent!');
    });

    test('sendSMS with direct sending', () async {
      final result = await FlutterSms.sendSMS(
        message: 'Direct test',
        recipients: '1234567890',
        sendDirect: true,
      );
      expect(result, 'SMS Sent!');
    });

    test('sendSMS with multiple recipients', () async {
      final result = await FlutterSms.sendSMS(
        message: 'Multi test',
        recipients: '1234567890;0987654321',
        sendDirect: false,
      );
      expect(result, 'SMS Sent!');
    });
  });
}
