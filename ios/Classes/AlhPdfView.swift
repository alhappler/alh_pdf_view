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
    
    // This channel is called by user actions, e. g. when to update the current page
    private var _pdfViewChannel: FlutterMethodChannel
    
    // This channel is only called inside the package and should not be used by the user, e. g. it handles updated configuration values
    private var _pdfChannel: FlutterMethodChannel
    
    private var configuration: AlhPdfViewConfiguration
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _pdfViewChannel = FlutterMethodChannel(name: "alh_pdf_view_\(viewId)", binaryMessenger: messenger!)
        _pdfChannel = FlutterMethodChannel(name: "alh_pdf_\(viewId)", binaryMessenger: messenger!)
        
        let arguments = args as! Dictionary<String, Any>
        configuration = AlhPdfViewConfiguration.init(arguments: arguments)
        _embeddedPdfView = EmbeddedPdfView.init(configuration: configuration)
        
        super.init()
        
        _pdfViewChannel.setMethodCallHandler(handle)
        _pdfChannel.setMethodCallHandler(handle)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        initSwipeGestures()
        
        DispatchQueue.main.async {
            self.handleRenderCompleted()
        }
        
        if let document = _embeddedPdfView.pdfView.document {
            initObservers()
            
        } else{
            let arguments = ["error" : "cannot create document: File not in PDF format or corrupted."]
            _pdfViewChannel.invokeMethod("onError", arguments: arguments)
        }
        
    }
    
    func view() -> UIView {
        return _embeddedPdfView
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
        case "pageCount":
            let pageCount = _embeddedPdfView.getPageCount() ?? -1
            result(pageCount)
            break
        case "currentPage":
            let currentPageIndex = _embeddedPdfView.getCurrentPageIndex() ?? -1
            result(currentPageIndex)
            break
        case "setPage":
            let arguments = call.arguments as! Dictionary<String, Any>
            let pageIndex = arguments["page"] as! Int
            _embeddedPdfView.goToPage(pageIndex: pageIndex)
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
            result(_embeddedPdfView.getCurrentLogicalScaleFactor())
            break
        case "setZoom":
            let arguments = call.arguments as! Dictionary<String, Any>
            let zoom = arguments["newZoom"] as! CGFloat
            self._embeddedPdfView.zoomPdfView(zoomFactor: zoom)
            result(nil)
            break
        case "updateCreationParams":
            let arguments = call.arguments as! Dictionary<String, Any>
            _embeddedPdfView.updateConfiguration(newConfiguration: AlhPdfViewConfiguration.init(arguments: arguments))
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
    
    func handleRenderCompleted() {
        let pagesCount = _embeddedPdfView.getPageCount() ?? -1
        _pdfViewChannel.invokeMethod("onRender", arguments: ["pages": pagesCount])
    }
    
    @objc func handlePageChanged(notification: NSNotification) {
        if let totalPagesCount = _embeddedPdfView.getPageCount(), let currentPageIndex = _embeddedPdfView.getCurrentPageIndex() {
            _pdfViewChannel.invokeMethod("onPageChanged", arguments: ["page": currentPageIndex, "total": totalPagesCount])
        }
    }
    
    @objc func handleZoomChanged(notification: NSNotification) {
        _pdfViewChannel.invokeMethod("onZoomChanged", arguments: ["zoom": self._embeddedPdfView.getCurrentLogicalScaleFactor()])
    }
}
