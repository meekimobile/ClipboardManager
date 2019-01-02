import Flutter
import UIKit

public class SwiftClipboardManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "clipboard_manager", binaryMessenger: registrar.messenger())
    let instance = SwiftClipboardManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "copyToClipBoard":
        guard let args = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid_arguments", message: "Arguments are missing.", details: nil))
            return
        }
        guard let contentType = args["contentType"] as? String else {
            result(FlutterError(code: "invalid_content_type", message: "Invalid content type.", details: nil))
            return
        }

        if (contentType.starts(with: "text/")) {
            if let thingToCopy = args["content"] as? String {
                UIPasteboard.general.string = thingToCopy
                result(true)
            } else {
                result(FlutterError(code: "invalid_content", message: "Invalid content.", details: nil))
            }

        } else if (contentType.starts(with: "image/")) {
            if let thingToCopy = args["content"] as? FlutterStandardTypedData {
                UIPasteboard.general.image = UIImage(data: thingToCopy.data)
                result(true)
            } else {
                result(FlutterError(code: "invalid_content", message: "Invalid content.", details: nil))
            }
            
        } else {
            result(FlutterError(code: "not_implemented", message: "Method is not implemented.", details: nil))
        }

    case "pasteFromClipBoard":
        var resMap = [String:Any]()
        if UIPasteboard.general.types.count <= 0 {
            resMap["contentType"] = "null"
            result(resMap)
            return
        }
        let pbTypes = UIPasteboard.general.types
        print("ClipboardManager pbTypes \(pbTypes)")
        if let image = UIPasteboard.general.image {
            resMap["contentType"] = "image/png"
            resMap["content"] = image.pngData()
            result(resMap)
            
        } else if let text = UIPasteboard.general.string {
            resMap["contentType"] = "text/plain"
            resMap["content"] = text
            result(resMap)
            
        } else {
            resMap["contentType"] = "null"
            result(resMap)
        }

    default:
        result(FlutterError(code: "not_implemented", message: "Method is not implemented.", details: nil))
    }
  }
}
