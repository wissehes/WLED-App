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
    
    /// Device's presets
    var presets: [WLEDPreset.Normalized] = []
    
    // MARK: Device state
    
    var isOnline: Bool = false
    var isPoweredOn: Bool = false
    /// Brightness level from 1 - 255
    var brightness: Float = 0
    var color: String?
    
    // MARK: Methods
    
    @MainActor
    func update() async {
        do {
            let device = try await self.api.getInfo()
            
            self.isOnline = true
            self.isPoweredOn = device.state.on
            self.brightness = device.state.brightness
            self.color = device.state.segments.first?.color?.toHex()
        } catch {
            self.isOnline = false
            print(error )
        }
        
        do {
            self.presets = try await self.api.getPresets()
        } catch { print(error) }
    }
    
    @MainActor
    func setOnOff(state: Bool) async {
        await self.api.setState(state)
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

extension Device {
    // MARK: Computed values
    
    var url: URL {
        URL(string: "http://\(address):\(port)")!
    }

    var api: WLED {
        WLED(baseUrl: self.url)
    }
    
    var actualColor: Color? {
        guard let color else { return nil }
        let uiColor = UIColor(hex: color)
        
        return Color(uiColor: uiColor)
    }
}
