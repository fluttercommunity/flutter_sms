import Flutter
import UIKit
import MessageUI

public class SwiftFlutterSmsPlugin: NSObject, FlutterPlugin, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    private var result: FlutterResult?
    private var _arguments = [String: Any]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_sms", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSmsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "sendSMS":
            _arguments = call.arguments as? [String: Any] ?? [:]
            
            #if targetEnvironment(simulator)
            result(FlutterError(
                code: "message_not_sent",
                message: "Cannot send message on this device!",
                details: "Cannot send SMS and MMS on a Simulator. Test on a real device."
            ))
            #else
            if MFMessageComposeViewController.canSendText() {
                self.result = result
                let controller = MFMessageComposeViewController()
                controller.body = _arguments["message"] as? String
                controller.recipients = _arguments["recipients"] as? [String]
                controller.messageComposeDelegate = self
                
                // Updated way to get the root view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootViewController = window.rootViewController {
                    
                    // Find the topmost presented view controller
                    var topController = rootViewController
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    topController.present(controller, animated: true, completion: nil)
                } else {
                    result(FlutterError(
                        code: "no_view_controller",
                        message: "Could not find a view controller to present the message composer.",
                        details: "Unable to access the root view controller for presenting the SMS interface."
                    ))
                }
            } else {
                result(FlutterError(
                    code: "device_not_capable",
                    message: "The current device is not capable of sending text messages.",
                    details: "A device may be unable to send messages if it does not support messaging or if it is not currently configured to send messages. This only applies to the ability to send text messages via iMessage, SMS, and MMS."
                ))
            }
            #endif
            
        case "canSendSMS":
            #if targetEnvironment(simulator)
            result(false)
            #else
            result(MFMessageComposeViewController.canSendText())
            #endif
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        let resultMap: [MessageComposeResult: String] = [
            .sent: "sent",
            .cancelled: "cancelled",
            .failed: "failed"
        ]
        
        if let callback = self.result {
            callback(resultMap[result] ?? "unknown")
            self.result = nil // Clear the callback to prevent memory leaks
        }
        
        // Updated dismissal method
        controller.dismiss(animated: true, completion: nil)
    }
}