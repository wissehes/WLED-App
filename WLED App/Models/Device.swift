//
//  Device.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import Foundation
import SwiftData
import UIKit

@Model class Device {
    // MARK: Device info
    
    /// IP Address of the device
    @Attribute(.unique) var address: String
    /// Device's mac address
    var macAddress: String
    /// Port number
    var port: String
    /// Device name
    var name: String
    
    // MARK: Device state
    
    var isOnline: Bool
    var isPoweredOn: Bool
    /// Brightness level from 1 - 255
    var brightness: Float
    var color: String?
    
    // MARK: Methods
    
    @MainActor
    func update() async {
        guard let device = try? await WLED.shared.getInfo(address: self.address, port: self.port) else {
            self.isOnline = false
            return
        }
        
        self.isOnline = true
        self.isPoweredOn = device.state.on
        self.brightness = device.state.brightness
        self.color = device.state.segments.first?.color?.toHex()
    }
    
    @MainActor
    func setOnOff(state: Bool) async {
        await WLED.shared.setState(state, address: self.address, port: self.port)
    }
    
    // MARK: Computed values
    
    var url: URL {
        URL(string: "http://\(address):\(port)")!
    }
    
    var actualColor: UIColor? {
        guard let color else { return nil }
        return UIColor(hex: color)
    }
    
    /// Default initializer
    init(address: String, macAddress: String, port: String, name: String, isOnline: Bool, isPoweredOn: Bool, brightness: Float, color: String? = nil) {
        self.address = address
        self.macAddress = macAddress
        self.port = port
        self.name = name
        self.isOnline = isOnline
        self.isPoweredOn = isPoweredOn
        self.brightness = brightness
        self.color = color
    }
    
    /// Initialize from a WLED response
    init(wled: WLEDStateResponse, port: String = "80") {
        self.address = wled.info.ip
        self.macAddress = wled.info.mac
        self.port = port
        self.name = wled.info.name

        self.isOnline = true
        self.isPoweredOn = wled.state.on
        self.brightness = wled.state.brightness
        self.color = wled.state.segments.first?.color?.toHex()
    }
}
