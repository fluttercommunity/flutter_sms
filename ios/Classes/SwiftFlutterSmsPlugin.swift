import Flutter
import UIKit
import MessageUI

public class SwiftFlutterSmsPlugin: NSObject, FlutterPlugin, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
  var message = "Please Send Message"
  var _arguments = [String: Any]()

  public static func register(with registrar: FlutterPluginRegistrar) {
  let channel = FlutterMethodChannel(name: "flutter_sms", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSmsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    _arguments = call.arguments as! [String : Any];
    switch call.method {
    case "sendSMS":
      let controller = MFMessageComposeViewController()
      controller.body = _arguments["message"] as? String
      controller.recipients = _arguments["recipients"] as? [String]
      controller.messageComposeDelegate = self
      UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
      result(message)
    default:
        result(FlutterMethodNotImplemented)
      break
    }
  }

  public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
      message = "Sent!"
  }
}
