[![Flutter Community: flutter_sms](https://fluttercommunity.dev/_github/header/flutter_sms)](https://github.com/fluttercommunity/community)

[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
![github pages](https://github.com/fluttercommunity/flutter_sms/workflows/github%20pages/badge.svg)
[![GitHub stars](https://img.shields.io/github/stars/fluttercommunity/flutter_sms?color=blue)](https://github.com/fluttercommunity/flutter_sms)
[![flutter_sms](https://img.shields.io/pub/v/flutter_sms.svg)](https://pub.dev/packages/flutter_sms)

# flutter_sms

![alt-text-1](https://github.com/fluttercommunity/flutter_sms/blob/master/screenshots/ios_blank.PNG)

Online Demo: https://fluttercommunity.github.io/flutter_sms/

## Description

Flutter Plugin for sending SMS and MMS on Android and iOS. If you send to more than one person it will send as MMS. On the iOS if the number is an iPhone and iMessage is enabled it will send as an iMessage.

## How To Use

You can send multiple ways:

1. Message and No People
2. People and No Message
3. Message and People

This will populate the correct fields.


## Example

Make sure to Install and Import the Package.

``` dart
import 'package:flutter_sms/flutter_sms.dart';
```

Create a function for sending messages.

``` dart
void _sendSMS(String message, List<String> recipents) async {
 String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
print(_result);
}
```

You can quickly send the message with this function.

``` dart
String message = "This is a test message!";
List<String> recipents = ["1234567890", "5556787676"];

_sendSMS(message, recipents);
```


## Sending Direct

**WARNING, there is a narrow category of apps that can get into the play store
using this feature. Using it is only advisable if you fit into this category or
you intent to distribute through a third party platform**

On Android, you can skip the additional dialog with the sendDirect parameter.

``` dart
String message = "This is a test message!";
List<String> recipents = ["1234567890", "5556787676"];

 String _result = await sendSMS(message: message, recipients: recipents, sendDirect: true)
        .catchError((onError) {
      print(onError);
    });
print(_result);
```

NOTE: This also requires the SEND_SMS permission to be added to the AndroidManifest.xml

```
    <uses-permission android:name="android.permission.SEND_SMS"/>
    
    <application
      ...
```


## Screenshots

iOS SMS             |  Android MMS
:-------------------------:|:-------------------------:
![alt-text-1](https://github.com/fluttercommunity/flutter_sms/blob/master/screenshots/ios_sms.PNG)  |  ![alt-text-2](https://github.com/fluttercommunity/flutter_sms/blob/master/screenshots/android_mms.png)

You can find other [screenshots here](https://github.com/fluttercommunity/flutter_sms/tree/master/screenshots).
