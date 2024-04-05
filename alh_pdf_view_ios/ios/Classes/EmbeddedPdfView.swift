//
//  EmbeddedPdfView.swift
//  alh_pdf_view
//
//  Created by André Börger on 31.03.22.
//

import Foundation
import PDFKit
import Flutter

class EmbeddedPdfView : UIView {
    let pdfView: PDFView
    
    // This factor is a translated value of the scale factor 1.0 that is used on flutter side
    private var initPdfViewScaleFactor: CGFloat
    
    private var hasInitializedView = false
    private var hasError = false
    
    private var configuration: AlhPdfViewConfiguration
    
    // Ensure to update after layoutSubviews was called to get correct sizes, e. g. after rotating the screen
    private var updatedConfiguration: AlhPdfViewConfiguration?
    
    private var pageChangeAnimationDuration: Double = 0.4
    private var zoomAnimationDuration: Double = 0.4
    
    private var pdfChannel: FlutterMethodChannel
    
    init(configuration: AlhPdfViewConfiguration, pdfChannel: FlutterMethodChannel) {
        self.configuration = configuration
        self.pdfView = PDFView.init(frame: .zero)
        self.initPdfViewScaleFactor = 0.0 // just a default value
        self.pdfChannel = pdfChannel
        
        super.init(frame: .zero)
        
        initPdfView()
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: self.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.hasError){
            return;
        }
        
        self.pdfView.usePageViewController(configuration.pageFling, withViewOptions: nil)
        
        if(!hasInitializedView) {
            initPdfDefaultScaleFactor()
            goToDefaultPage()
            initializeScrollbar()
        } else if let updatedConfiguration = self.updatedConfiguration {
            handleUpdatedConfiguration(updatedConfiguration: updatedConfiguration)
        }
        hasInitializedView = true
    }
    
    private func initPdfView() {
        if let document = initPdfDcoument() {
            self.pdfView.autoresizesSubviews = true
            self.pdfView.autoresizingMask = .flexibleWidth
            self.pdfView.displayDirection = configuration.swipeHorizontal ? .horizontal : .vertical
            self.pdfView.backgroundColor = configuration.backgroundColor
            self.pdfView.document = document
            self.pdfView.displayMode = .singlePageContinuous
            self.pdfView.delegate = self
            self.pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(configuration.spacing), right: 0)
            
            if(document.isEncrypted){
                document.unlock(withPassword: configuration.password)
            }
        }
        else {
            self.pdfChannel.invokeMethod("onError", arguments: [
                "error": "Failure initialising pdf document!"
            ])
            
            self.hasError = true;
        }
    }
    
    private func initializeScrollbar() {
        for view in pdfView.subviews {
            if let scrollView = findUIScrollView(of: view) {
                scrollView.showsHorizontalScrollIndicator = configuration.showScrollbar
                scrollView.showsVerticalScrollIndicator = configuration.showScrollbar
            }
        }
    }
    
    private func findUIScrollView(of uiView: UIView) -> UIScrollView? {
        if let scrollView = uiView as? UIScrollView {
            return scrollView
        }
        
        for view in uiView.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
            
            if !view.subviews.isEmpty {
                return findUIScrollView(of: view)
            }
        }
        
        return nil
    }
    
    /**
     Initalize PDFDocument with the path or bytes and returns that.
     */
    func initPdfDcoument() -> PDFDocument? {
        if let path = configuration.filePath {
            let url = URL.init(fileURLWithPath: path)
            return PDFDocument.init(url: url)
        } else if let bytes = configuration.bytes {
            return PDFDocument.init(data: bytes)
        } else {
            return nil
        }
    }
    
    func updateConfiguration(newConfiguration: AlhPdfViewConfiguration) {
        updatedConfiguration = newConfiguration
    }
    
    private func initPdfDefaultScaleFactor() {
        let initScaleFactor = getPdfScaleFactor()
        initPdfViewScaleFactor = initScaleFactor
        self.pdfView.scaleFactor = configuration.defaultZoomFactor * initScaleFactor
        self.pdfView.minScaleFactor = configuration.minZoom * initScaleFactor
        self.pdfView.maxScaleFactor = configuration.maxZoom * initScaleFactor
    }
    
    /**
     The calculated scale factor depends on the fitPolicy.
     */
    private func getPdfScaleFactor() -> CGFloat {
        let parentSize = self.frame.size
        let pageSize = getPdfPageSize()
        
        switch(configuration.fitPolicy) {
        case FitPolicy.both:
            if(parentSize.height > parentSize.width) {
                return self.pdfView.scaleFactorForSizeToFit // works only for width
            } else {
                return parentSize.height / pageSize.height
            }
        case FitPolicy.height:
            return parentSize.height / pageSize.height
        case FitPolicy.width:
            return self.pdfView.scaleFactorForSizeToFit // works only for width
        }
    }
    
    private func goToDefaultPage() {
        if let document = self.pdfView.document {
            let pageCount = document.pageCount;
            let defaultPage = configuration.defaultPage < pageCount ? configuration.defaultPage : pageCount - 1
            self.pdfView.go(to: document.page(at: defaultPage)!)
        }
    }
    
    private func handleUpdatedConfiguration(updatedConfiguration: AlhPdfViewConfiguration) {
        if(updatedConfiguration.fitPolicy != configuration.fitPolicy) {
            self.configuration = updatedConfiguration
            initPdfDefaultScaleFactor()
        }
        if(updatedConfiguration.showScrollbar != configuration.showScrollbar) {
            initializeScrollbar()
        }
        self.updatedConfiguration = nil
    }
    
    func getPdfPageSize() -> CGSize {
        let document = self.pdfView.document!
        let pageCount = document.pageCount
        let defaultPage = configuration.defaultPage > pageCount ? configuration.defaultPage : pageCount - 1
        let pdfPage = document.page(at: defaultPage)!
        let initialPageRect = pdfPage.bounds(for: self.pdfView.displayBox)
        
        return CGSize(width: initialPageRect.size.width, height:  initialPageRect.size.height)
    }
    
    /**
     Translates the scaleFactor of PdfView to a scale factor that is used on flutter side.
     */
    func getCurrentLogicalScaleFactor() -> CGFloat {
        return pdfView.scaleFactor / self.initPdfViewScaleFactor
    }
    
    func zoomPdfView(zoomFactor: CGFloat) {
        let updatedScaleFactor = self.initPdfViewScaleFactor * zoomFactor
        UIView.animate(withDuration: zoomAnimationDuration) {
            self.pdfView.scaleFactor = updatedScaleFactor
        }
        
    }
    
    func resetPdfZoom() {
        self.pdfView.scaleFactor = self.initPdfViewScaleFactor * configuration.defaultZoomFactor
    }
    
    func goToPage(pageIndex: Int, withAnimation: Bool) -> Bool {
        if let page = pdfView.document?.page(at: pageIndex) {
            if(withAnimation) {
                UIView.animate(withDuration: pageChangeAnimationDuration) {
                    self.pdfView.go(to: page)
                }
            } else {
                self.pdfView.go(to: page)
            }
            
            return true
        }
        return false
    }
    
    func getCurrentPageIndex() -> Int? {
        if let currentPage = pdfView.currentPage {
            return pdfView.document?.index(for: currentPage)
        }
        return nil
    }
    
    func getPageCount() -> Int? {
        if let document = self.pdfView.document {
            return document.pageCount;
        }
        return nil
    }
    
    func handleSwipe(gesture: UISwipeGestureRecognizer) {
        if(gesture.direction == .left) {
            _ = goToNextPage(withAnimation: true)
        } else if (gesture.direction == .right){
            _ = goToPreviousPage(withAnimation: true)
        }
    }
    
    func goToNextPage(withAnimation: Bool) -> Bool {
        if(pdfView.canGoToNextPage) {
            if(withAnimation) {
                UIView.animate(withDuration: pageChangeAnimationDuration) {
                    self.pdfView.goToNextPage(nil)
                }
            } else {
                pdfView.goToNextPage(nil)
            }
            return true
        }
        return false
    }
    
    func goToPreviousPage(withAnimation: Bool) -> Bool {
        if(pdfView.canGoToPreviousPage) {
            if(withAnimation) {
                UIView.animate(withDuration: pageChangeAnimationDuration) {
                    self.pdfView.goToPreviousPage(nil)
                }
            } else {
                pdfView.goToPreviousPage(nil)
            }
            return true
        }
        return false
    }
}

extension EmbeddedPdfView : PDFViewDelegate {
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        
        // If onLinkHandle is provided, call the method, otherwise open the URL in the browser
        if(self.configuration.hasOnLinkHandle) {
            self.pdfChannel.invokeMethod("onLinkHandle", arguments: ["url": url.absoluteString])
        } else {
            UIApplication.shared.open(url)
        }
    }
}
