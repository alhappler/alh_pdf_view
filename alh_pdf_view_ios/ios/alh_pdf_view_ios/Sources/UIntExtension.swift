//
//  UIntExtension.swift
//  alh_pdf_view
//
//  Created by André Börger on 29.03.22.
//

import Foundation

extension UInt {
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((self & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
