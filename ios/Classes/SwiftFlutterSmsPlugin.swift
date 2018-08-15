import Flutter
import UIKit
import MessageUI

public class SwiftFlutterSmsPlugin: NSObject, FlutterPlugin, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
  var message = "Please Send Message"
//   let flutterViewController: FlutterViewController
//  let channel: FlutterMethodChannel

  public static func register(with registrar: FlutterPluginRegistrar) {
  let channel = FlutterMethodChannel(name: "flutter_sms", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSmsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "sendSMS":
      //        let sourceType: UIImagePickerControllerSourceType = "camera" == (call.arguments as? String) ? .camera : .photoLibrary
      let controller = MFMessageComposeViewController()
      controller.body = "call.arguments"
      controller.recipients = ["1234567890"]
      controller.messageComposeDelegate = self
      //        let messagePicker = self.buildMessageUI( message: "Test", recipients: ["2051234567"], completion: result)
//      self.flutterViewController.present(controller, animated: true, completion: nil)
      UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    default:
      break
    }
  }

//  init(flutterViewController: FlutterViewController) {
//
//    self.flutterViewController = flutterViewController
////    channel = FlutterMethodChannel(name: "flutter_sms", binaryMessenger: flutterViewController)
////    let instance = SwiftFlutterSmsPlugin(flutterViewController: flutterViewController)
//  }

  public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
      message = "Sent!"
  }

//  func buildMessageUI(message: String, recipients: [String], completion: @escaping (_ result: Any?) -> Void) -> UIViewController {
//    if message.isEmpty {
//      let alert = UIAlertController(title: "Error", message: "Message Required", preferredStyle: .alert)
//      alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
//        completion(FlutterError(code: "message_error", message: "message not available", details: nil))
//      })
//      return alert
//    } else {
//
////      return  MFMessageComposeViewController() {
////        self.flutterViewController.dismiss(animated: true, completion: nil)
////        if let image = image {
////          completion(self.saveToFile(image: image))
////        } else {
////          completion(FlutterError(code: "user_cancelled", message: "User did cancel", details: nil))
////        }
////      }
//    }
//  }

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

class ECMMessageComposerBuilder: NSObject {

  @objc private dynamic var customWindow: UIWindow?
    private var body: String?
    private var phoneNumber: String?
    fileprivate var messageController: MFMessageComposeViewController?

    var canCompose: Bool {
        return MFMessageComposeViewController.canSendText()
    }

    func body(_ body: String?) -> ECMMessageComposerBuilder {
        self.body = body
        return self
    }

    func phoneNumber(_ phone: String?) -> ECMMessageComposerBuilder {
        self.phoneNumber = phone
        return self
    }

    func build() -> UIViewController? {
        guard canCompose else { return nil }

        messageController = MFMessageComposeViewController()
        messageController?.body = body
        if let phone = phoneNumber {
            messageController?.recipients = [phone]
        }
        messageController?.messageComposeDelegate = self

        return messageController
    }

    func show() {
        customWindow = UIWindow(frame: UIScreen.main.bounds)
        customWindow?.rootViewController = UIViewController()

        // Move it to the top
        let topWindow = UIApplication.shared.windows.last
        customWindow?.windowLevel = (topWindow?.windowLevel ?? 0) + 1

        // and present it
        customWindow?.makeKeyAndVisible()

        if let messageController = build() {
            customWindow?.rootViewController?.present(messageController, animated: true, completion: nil)
        }
    }

    func hide(animated: Bool = true) {
        messageController?.dismiss(animated: animated, completion: nil)
        messageController = nil
        customWindow?.isHidden = true
        customWindow = nil
    }
}

extension ECMMessageComposerBuilder: MFMessageComposeViewControllerDelegate {

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        hide()
    }
}
