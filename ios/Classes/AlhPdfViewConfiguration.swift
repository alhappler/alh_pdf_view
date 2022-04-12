//
//  AlhPdfViewConfiguration.swift
//  alh_pdf_view
//
//  Created by André Börger on 29.03.22.
//

import Foundation

class AlhPdfViewConfiguration {
    var filePath: String?
    var bytes: Data?
    var enableSwipe: Bool
    var fitPolicy: FitPolicy
    var fitEachPage: Bool
    var swipeHorizontal: Bool
    var password: String
    var nightMode: Bool
    var autoSpacing: Bool
    var pageFling: Bool
    var pageSnap: Bool
    var enableDoubleTap: Bool
    var defaultPage: Int
    var defaultZoomFactor: CGFloat
    var backgroundColor: UIColor
    var minZoom: CGFloat
    var maxZoom: CGFloat
    
    init(arguments: Dictionary<String, Any>) {
        self.filePath = arguments["filePath"] as? String
        
        if let flutterBytes = arguments["bytes"] as? FlutterStandardTypedData {
            self.bytes = flutterBytes.data
        }
    
        self.enableSwipe = arguments["enableSwipe"] as! Bool
        self.fitPolicy = FitPolicy.init(value: arguments["fitPolicy"] as! String)
        self.fitEachPage = arguments["fitEachPage"] as! Bool
        self.swipeHorizontal = arguments["swipeHorizontal"] as! Bool
        self.password = arguments["password"] as! String
        self.nightMode = arguments["nightMode"] as! Bool
        self.autoSpacing = arguments["autoSpacing"] as! Bool
        self.pageFling = arguments["pageFling"] as! Bool
        self.pageSnap = arguments["pageSnap"] as! Bool
        self.enableDoubleTap = arguments["enableDoubleTap"] as! Bool
        self.defaultPage = arguments["defaultPage"] as! Int
        self.defaultZoomFactor = arguments["defaultZoomFactor"] as! CGFloat
        self.backgroundColor = (arguments["backgroundColor"] as! UInt).toUIColor()
        self.minZoom = arguments["minZoom"] as! CGFloat
        self.maxZoom = arguments["maxZoom"] as! CGFloat
    }
}

enum FitPolicy: String {
    case both, height, width
    
    init(value: String) {
        switch(value) {
            case "FitPolicy.both": self =  FitPolicy.both
            case "FitPolicy.width": self =  FitPolicy.width
            case "FitPolicy.height": self =  FitPolicy.height
            default: self = FitPolicy.both
        }
    }
}
