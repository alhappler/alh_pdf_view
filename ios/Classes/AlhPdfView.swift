//
//  AlhPdfView.swift
//  alh_pdf_view
//
//  Created by André Börger on 29.03.22.
//

import Foundation
import Flutter
import UIKit
import PDFKit

class AlhPdfViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AlhPdfView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AlhPdfView: NSObject, FlutterPlatformView {
    private var _embeddedPdfView: EmbeddedPdfView
    
    private var _channel: FlutterMethodChannel
    
    private var configuration: AlhPdfViewConfiguration
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _channel = FlutterMethodChannel(name: "alh_pdf_view_\(viewId)", binaryMessenger: messenger!)
        
        let arguments = args as! Dictionary<String, Any>
        configuration = AlhPdfViewConfiguration.init(arguments: arguments)
        _embeddedPdfView = EmbeddedPdfView.init(configuration: configuration)
        
        super.init()
        
        _channel.setMethodCallHandler(handle)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        initSwipeGestures()
        
        if let document = _embeddedPdfView.pdfView.document {
            initObservers()
            DispatchQueue.main.async {
                self.handleRenderCompleted(pages: document.pageCount as NSNumber)
            }
        } else{
            let arguments = ["error" : "cannot create document: File not in PDF format or corrupted."]
            _channel.invokeMethod("onError", arguments: arguments)
        }
        
    }
    
    func view() -> UIView {
        return _embeddedPdfView
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let pdfView = _embeddedPdfView.pdfView
        
        switch(call.method) {
        case "pageCount":
            let pageCount = pdfView.document?.pageCount
            result(pageCount)
            break
        case "currentPage":
            if let currentPage = pdfView.currentPage {
                let currentPageIndex = pdfView.document?.index(for: currentPage)
                result(currentPageIndex)
            }
            result(-1)
            break
        case "setPage":
            let arguments = call.arguments as! Dictionary<String, Any>
            let pageIndex = arguments["page"] as! Int
            if let page = pdfView.document?.page(at: pageIndex) {
                pdfView.go(to: page)
            }
            result(nil)
            break
        case "pageSize":
            let pageSize = self._embeddedPdfView.getPdfPageSize()
            let pageWidth = pageSize.width
            let pageHeight = pageSize.height
            result(["width": pageWidth, "height": pageHeight])
            break
        case "resetZoom":
            self._embeddedPdfView.resetPdfZoom()
            result(nil)
            break
        case "currentZoom":
            result(pdfView.scaleFactor)
            break
        case "setZoom":
            let arguments = call.arguments as! Dictionary<String, Any>
            let zoom = arguments["newZoom"] as! CGFloat
            self._embeddedPdfView.zoomPdfView(zoomFactor: zoom)
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func initSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(didSwipe))
        swipeLeft.direction = .left
        self.view().addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer.init(target: self, action: #selector(didSwipe))
        swipeRight.direction = .right
        self.view().addGestureRecognizer(swipeRight)
    }
    
    @objc func didSwipe(gesture: UISwipeGestureRecognizer) {
        let pdfView = _embeddedPdfView.pdfView
        if(gesture.direction == .left) {
            if(pdfView.canGoToNextPage) {
                pdfView.goToNextPage(nil)
            }
        } else if (gesture.direction == .right){
            if(pdfView.canGoToPreviousPage) {
                pdfView.goToPreviousPage(nil)
            }
        }
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePageChanged(notification:)), name: Notification.Name.PDFViewPageChanged, object: self._embeddedPdfView.pdfView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleZoomChanged(notification:)), name: Notification.Name.PDFViewScaleChanged, object: nil)
    }
    
    func handleRenderCompleted(pages: NSNumber) {
        _channel.invokeMethod("onRender", arguments: ["pages": pages])
    }
    
    @objc func handlePageChanged(notification: NSNotification) {
        let pdfView = _embeddedPdfView.pdfView
        
        if let document = pdfView.document, let currentPage = pdfView.currentPage {
            let page = document.index(for: currentPage) as NSNumber
            let total = document.pageCount as NSNumber
            _channel.invokeMethod("onPageChanged", arguments: ["page": page, "total": total])
        }
    }
    
    @objc func handleZoomChanged(notification: NSNotification) {
        _channel.invokeMethod("onZoomChanged", arguments: ["zoom": self._embeddedPdfView.getCurrentLogicalScaleFactor()])
    }
}
