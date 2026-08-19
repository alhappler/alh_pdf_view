import Flutter
import UIKit

public class AlhPdfViewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "alh_pdf_view", binaryMessenger: registrar.messenger())
      let instance = AlhPdfViewPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
        
      let alhPdfViewFactory = AlhPdfViewFactory(messenger: registrar.messenger())
      registrar.register(alhPdfViewFactory, withId: "alh_pdf_view")
    }
}
