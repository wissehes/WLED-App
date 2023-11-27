//
//  Device.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import Foundation
import SwiftData

@Model class Device {
    // MARK: Device info
    
    /// IP Address of the device
    @Attribute(.unique) var address: String
    /// Port number
    var port: String
    /// Device name
    var name: String
    
    // MARK: Device state
    
    var isOnline: Bool
    var isPoweredOn: Bool
    
    init(address: String, port: String, name: String, isOnline: Bool = false, isPoweredOn: Bool = false) {
        self.address = address
        self.port = port
        self.name = name
        self.isOnline = isOnline
        self.isPoweredOn = isPoweredOn
    }
}
