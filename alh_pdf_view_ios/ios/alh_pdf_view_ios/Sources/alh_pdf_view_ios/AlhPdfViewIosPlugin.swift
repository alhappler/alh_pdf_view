import Flutter
import UIKit

public class AlhPdfViewIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
      let alhPdfViewFactory = AlhPdfViewFactory(messenger: registrar.messenger())
      registrar.register(alhPdfViewFactory, withId: "alh_pdf_view")
    }
}
