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
    default:
      break
    }
  }

  public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
      message = "Sent!"
  }

  private func saveToFile(image: UIImage) -> Any {
    guard let data = UIImageJPEGRepresentation(image, 1.0) else {
      return FlutterError(code: "image_encoding_error", message: "Could not read image", details: nil)
    }
    let tempDir = NSTemporaryDirectory()
    let imageName = "image_picker_\(ProcessInfo().globallyUniqueString).jpg"
    let filePath = tempDir.appending(imageName)
    if FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil) {
      return filePath
    } else {
      return FlutterError(code: "image_save_failed", message: "Could not save image to disk", details: nil)
    }
  }
}
