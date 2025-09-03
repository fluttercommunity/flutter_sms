# send_message 📱

[![pub.dev](https://img.shields.io/pub/v/send_message.svg)](https://pub.dev/packages/send_message)
[![GitHub](https://img.shields.io/github/license/DabhiNavaghan/send_message.svg)](https://github.com/DabhiNavaghan/send_message/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue.svg)](https://github.com/DabhiNavaghan/send_message)

A **actively maintained** Flutter plugin for sending SMS and MMS messages on Android, iOS, and Web platforms. This plugin automatically handles iMessage on iOS when available.

## 🚀 Why This Fork?

This plugin is **forked from [flutter_sms](https://pub.dev/packages/flutter_sms)** by **Navaghan Dabhi** due to:

- ❌ **No active maintenance** of the original package
- ❌ **No recent updates** or bug fixes
- ❌ **Lack of community activity** and support
- ✅ **Ensuring continued support** and updates
- ✅ **Bug fixes** and improvements
- ✅ **Active maintenance** and community support

## ✨ Features

- 📱 **Cross-platform**: Android, iOS, and Web support
- 💬 **SMS & MMS**: Send both text and multimedia messages
- 📞 **Multiple recipients**: Send to one or multiple contacts
- 🍎 **iMessage integration**: Automatic iMessage support on iOS
- 🚀 **Direct sending**: Skip confirmation dialogs (Android)
- 🔧 **Easy integration**: Simple and intuitive API

## 🛠️ Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  send_message: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📋 Platform Setup

### Android

For direct SMS sending (without confirmation dialog), add this permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SEND_SMS"/>
```

### iOS

No additional setup required. The plugin works out of the box and will use iMessage when available.

### Web

Web platform opens the default mail client with pre-filled message content.

## 🚀 Quick Start

Import the package:

```dart
import 'package:send_message/send_message.dart';
```

### Basic Usage

```dart
// Simple SMS sending
Future<void> send_simple_sms() async {
  String message = "Hello from send_message plugin!";
  List<String> recipients = ["1234567890"];
  
  try {
    String result = await sendSMS(
      message: message, 
      recipients: recipients
    );
    print("SMS sent: $result");
  } catch (error) {
    print("Error: $error");
  }
}
```

### Advanced Usage

```dart
// Send with multiple recipients and custom options
Future<void> send_advanced_sms() async {
  String message = "Hello everyone!";
  List<String> recipients = ["1234567890", "0987654321", "5556667777"];
  
  try {
    String result = await sendSMS(
      message: message,
      recipients: recipients,
      send_direct: true,  // Skip confirmation dialog (Android only)
    );
    print("SMS sent: $result");
  } catch (error) {
    print("Error: $error");
  }
}
```

### Check SMS Capability

```dart
Future<void> check_sms_capability() async {
  bool can_send = await canSendSMS();
  
  if (can_send) {
    print("Device can send SMS");
  } else {
    print("Device cannot send SMS");
  }
}
```

## 📖 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:send_message/send_message.dart';

class SmsScreen extends StatefulWidget {
  @override
  _SmsScreenState createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final TextEditingController _message_controller = TextEditingController();
  final TextEditingController _phone_controller = TextEditingController();
  List<String> recipients = [];

  Future<void> _send_sms() async {
    if (_message_controller.text.isEmpty || recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter message and recipients')),
      );
      return;
    }

    try {
      String result = await sendSMS(
        message: _message_controller.text,
        recipients: recipients,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS sent successfully: $result')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send SMS')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phone_controller,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_phone_controller.text.isNotEmpty) {
                      setState(() {
                        recipients.add(_phone_controller.text);
                        _phone_controller.clear();
                      });
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _message_controller,
              decoration: InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            if (recipients.isNotEmpty)
              Wrap(
                children: recipients.map((phone) => Chip(
                  label: Text(phone),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () => setState(() => recipients.remove(phone)),
                )).toList(),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _send_sms,
              child: Text('Send SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📚 API Reference

### `sendSMS()`

Sends an SMS/MMS message to specified recipients.

```dart
Future<String> sendSMS({
  required String message,        // The message content
  required List<String> recipients, // List of phone numbers
  bool send_direct = false,       // Skip confirmation dialog (Android only)
})
```

**Parameters:**
- `message`: The text message to send
- `recipients`: List of phone numbers (with or without country codes)
- `send_direct`: If `true`, sends directly without confirmation (Android only)

**Returns:** A `String` indicating the result of the operation.

### `canSendSMS()`

Checks if the device can send SMS messages.

```dart
Future<bool> canSendSMS()
```

**Returns:** `true` if the device can send SMS, `false` otherwise.

## 🔧 Usage Options

| Option | Description | Platform |
|--------|-------------|----------|
| **Message only** | Pre-fill message, let user choose recipients | All |
| **Recipients only** | Pre-fill recipients, let user type message | All |
| **Message + Recipients** | Complete SMS ready to send | All |
| **Direct send** | Skip confirmation dialog | Android only |

## ⚠️ Important Notes

### Direct Sending Warning

**WARNING**: Using `send_direct: true` is only recommended for specific app categories. Most apps should use the default behavior to comply with Play Store policies.

### iOS Behavior

- On iOS, if the recipient has an iPhone and iMessage is enabled, the message will be sent as an iMessage
- For multiple recipients, the message will be sent as MMS
- The plugin must be tested on a real iOS device

### Web Limitations

- Web platform opens the default mail client instead of SMS
- Direct sending is not available on web

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/DabhiNavaghan/send_message.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes and test them
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Maintainer

**Navaghan Dabhi** ([@DabhiNavaghan](https://github.com/DabhiNavaghan))

- 🌐 Portfolio: [navaghandahbi.dev](https://navaghandahbi.dev)
- 🐱 GitHub: [DabhiNavaghan](https://github.com/DabhiNavaghan)

## 🙏 Acknowledgments

- Original [flutter_sms](https://pub.dev/packages/flutter_sms) package by Flutter Community
- Flutter team for the amazing framework
- All contributors who help improve this plugin

## 📈 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

---

**⭐ If this plugin helped you, please give it a star! ⭐**