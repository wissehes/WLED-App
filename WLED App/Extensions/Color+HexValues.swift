//
//  Color+HexValues.swift
//  WLED App
//
//  Created by Wisse Hes on 29/11/2023.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    /// Initialize a color from a hex string
    public convenience init(hex: String) {
        var hexVal = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexVal.hasPrefix("#") {
            hexVal.remove(at: hex.startIndex)
        }
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexVal).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let blue = CGFloat(rgb & 0x0000FF) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    /// Converts the color to a hex string and returns it
    func toHex() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        return hexString
    }
}
