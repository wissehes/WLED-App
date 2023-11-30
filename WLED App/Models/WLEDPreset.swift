//
//  WLEDPreset.swift
//  WLED App
//
//  Created by Wisse Hes on 30/11/2023.
//

import Foundation
import UIKit

typealias WLEDPresets = [String: WLEDPreset]

struct WLEDPreset: Codable {
    let name: String?
    let segments: [WLEDState.Segment]?
    
    enum CodingKeys: String, CodingKey {
        case name = "n"
        case segments = "seg"
    }
    
    struct Normalized: Identifiable {
        let name: String
        let id: String
        let color: UIColor?
        
        init?(_ preset: WLEDPreset, id: String) {
            guard let name = preset.name, let segments = preset.segments else { return nil }
            
            self.name = name
            self.color = segments.first?.color
            self.id = id
        }
    }
}
