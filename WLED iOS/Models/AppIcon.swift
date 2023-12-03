//
//  AppIcon.swift
//  WLED App
//
//  Created by Wisse Hes on 01/12/2023.
//

import Foundation
import UIKit

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case rgb = "AppIcon-RGB"
    case rainbow = "AppIcon-Rainbow"
    
    var id: String { rawValue }
    
    var iconName: String? {
        if self == .primary {
            // Return `nil` to reset the icon to its primary icon
            return nil
        } else {
            return rawValue
        }
    }
    
    var description: String {
        switch self {
        case .primary:
            return "Default icon"
        case .rgb:
            return "RGB icon"
        case .rainbow:
            return "Rainbow icon"
        }
    }
    
    var preview: UIImage {
        UIImage(named: rawValue + "-Preview") ?? UIImage()
    }
}
