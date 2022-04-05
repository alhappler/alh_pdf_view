//
//  EmbeddedPdfView.swift
//  alh_pdf_view
//
//  Created by André Börger on 31.03.22.
//

import Foundation
import PDFKit

class EmbeddedPdfView : UIView {
    let pdfView: PDFView
    private let configuration: AlhPdfViewConfiguration
    
    // This factor should equals the scale factor of 1.0
    var initPdfViewScaleFactor: CGFloat = 0.0
    
    init(configuration: AlhPdfViewConfiguration) {
        self.configuration = configuration
        self.pdfView = PDFView.init(frame: .zero)
        
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
        
        self.pdfView.usePageViewController(configuration.pageFling, withViewOptions: nil)
        initPdfScaleFactor()
        if let document = self.pdfView.document {
            let pageCount = document.pageCount;
            let defaultPage = configuration.defaultPage < pageCount ? configuration.defaultPage : pageCount - 1
            self.pdfView.go(to: document.page(at: defaultPage)!)
        }
    }
    
    private func initPdfView() {
        if let document = initPdfDcoument() {
            self.pdfView.autoresizesSubviews = true
            self.pdfView.autoresizingMask = .flexibleWidth
            self.pdfView.displayDirection = configuration.swipeHorizontal ? .horizontal : .vertical
            self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
            self.pdfView.maxScaleFactor = 4.0
            self.pdfView.backgroundColor = configuration.backgroundColor
            self.pdfView.document = document
            self.pdfView.displayMode = .singlePageContinuous
            
            if(document.isEncrypted){
                document.unlock(withPassword: configuration.password)
            }
        }
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
    
    func initPdfScaleFactor() {
        let initScaleFactor = getPdfScaleFactor()
        initPdfViewScaleFactor = initScaleFactor
        self.pdfView.scaleFactor = initScaleFactor * configuration.defaultZoomFactor

        // fixes the problem when changing the scale factor that the pdfView is not on top
        if let scrollView = pdfView.subviews.first as? UIScrollView {
            // scrollView.contentOffset.y = 0.0
        }
    }
    
    /**
     The calculated scale factor is equal to 1.0 and depends on the fitPolicy.
     */
    private func getPdfScaleFactor() -> CGFloat {
        let parentSize = self.frame.size
        let pageSize = getPdfPageSize()
        
        switch(configuration.fitPolicy) {
        case FitPolicy.both:
            if(parentSize.height > parentSize.width) {
                return parentSize.width / pageSize.width
            } else {
                return parentSize.height / pageSize.height
            }
        case FitPolicy.height:
            return parentSize.height / pageSize.height
        case FitPolicy.width:
            return parentSize.width / pageSize.width
        }
        
    }
    
    func getPdfPageSize() -> CGSize {
        let document = pdfView.document!
        let pageCount = document.pageCount
        let defaultPage = configuration.defaultPage > pageCount ? configuration.defaultPage : pageCount - 1
        let pdfPage = document.page(at: defaultPage)!
        
        let initialPageRect = pdfPage.bounds(for: self.pdfView.displayBox)
        
        return CGSize(width: initialPageRect.size.width, height:  initialPageRect.size.height)
    }
    
    /**
     Translates the scaleFactor of PdfView to a scaleFactor that is more logical for the user.
     
     E. g. the scaleFactor 1 means that the whole pdf page should be visible depending on the fitpolicy.
     Usually the PdfView is using another scaleFactor, e. g. 1 would equal 0.5.
     */
    func getCurrentLogicalScaleFactor() -> CGFloat {
        return pdfView.scaleFactor / self.initPdfViewScaleFactor
    }
    
    func zoomPdfView(zoomFactor: CGFloat) {
        let updatedScaleFactor = self.initPdfViewScaleFactor * zoomFactor
        self.pdfView.scaleFactor = updatedScaleFactor
    }
    
    func resetPdfZoom() {
        self.pdfView.scaleFactor = self.initPdfViewScaleFactor * configuration.defaultZoomFactor
    }
}
