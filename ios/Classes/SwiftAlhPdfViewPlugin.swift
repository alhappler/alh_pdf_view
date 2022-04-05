import Flutter
import UIKit

public class SwiftAlhPdfViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "alh_pdf_view", binaryMessenger: registrar.messenger())
    let instance = SwiftAlhPdfViewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
    let alhPdfViewFactory = AlhPdfViewFactory(messenger: registrar.messenger())
    registrar.register(alhPdfViewFactory, withId: "alh_pdf_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
