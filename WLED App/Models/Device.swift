//
//  Device.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import Foundation
import SwiftData
import UIKit
import SwiftUI

@Model class Device {
    let id = UUID()
    
    // MARK: Device info
    
    /// IP Address of the device
    var address: String = "0.0.0.0"
    /// Device's mac address
    var macAddress: String?
    /// Port number
    var port: String = "80"
    /// Device name
    var name: String = "WLED"
    
    // MARK: Device state
    
    var isOnline: Bool = false
    var isPoweredOn: Bool = false
    /// Brightness level from 1 - 255
    var brightness: Float = 0
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
    
    var actualColor: Color? {
        guard let color else { return nil }
        let uiColor = UIColor(hex: color)
        
        return Color(uiColor: uiColor)
    }
    
    /// Default initializer
    init(
        address: String?,
        macAddress: String?,
        port: String?,
        name: String?,
        isOnline: Bool?,
        isPoweredOn: Bool?,
        brightness: Float?,
        color: String?
    ) {
        self.address = address ?? "0.0.0.0"
        self.macAddress = macAddress
        self.port = port ?? "80"
        self.name = name ?? "WLED"
        self.isOnline = isOnline ?? false
        self.isPoweredOn = isPoweredOn ?? false
        self.brightness = brightness ?? 0
        self.color = color
    }
    
    /// Initialize from a WLED response
    convenience init(wled: WLEDStateResponse, port: String = "80") {
        self.init(
            address: wled.info.ip,
            macAddress: wled.info.mac,
            port: port, 
            name: wled.info.name,
            
            isOnline: true,
            isPoweredOn: wled.state.on,
            brightness: wled.state.brightness,
            color: wled.state.segments.first?.color?.toHex()
        )
    }
}
