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
    var preset: WLEDPreset.Normalized?
    
    // MARK: Methods
    
    /// Updates the current state of the device
    @MainActor
    func update() async {
        var device: WLEDStateResponse? = nil
        
        do {
            device = try await self.api.getInfo()
            guard let device else { return }
            
            self.update(response: device)
        } catch {
            self.isOnline = false
            print(error )
        }
        
        do {
            self.presets = try await self.api.getPresets()
            self.preset = self.presets.first(where: { $0.id == device?.state.presetId.description })
        } catch { print(error) }
    }
    
    /// Update this device's state using the WLED API Response
    func update(response: WLEDStateResponse) {
        self.isOnline = true
        self.isPoweredOn = response.state.on
        self.brightness = response.state.brightness
        self.color = response.state.segments.first?.color?.toHex()
        
        self.preset = self.presets.first(where: { $0.id == response.state.presetId.description })
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
        presets: [WLEDPreset.Normalized]?,
        isOnline: Bool?,
        isPoweredOn: Bool?,
        brightness: Float?,
        color: String?,
        preset: WLEDPreset.Normalized?
    ) {
        self.address = address ?? "0.0.0.0"
        self.macAddress = macAddress
        self.port = port ?? "80"
        self.name = name ?? "WLED"
        self.presets = presets ?? []
        self.isOnline = isOnline ?? false
        self.isPoweredOn = isPoweredOn ?? false
        self.brightness = brightness ?? 0
        self.color = color
        self.preset = preset
    }
    
    /// Initialize from a WLED response
    convenience init(wled: WLEDStateResponse, port: String = "80") {
        self.init(
            address: wled.info.ip,
            macAddress: wled.info.mac,
            port: port, 
            name: wled.info.name,
            presets: [],
            
            isOnline: true,
            isPoweredOn: wled.state.on,
            brightness: wled.state.brightness,
            color: wled.state.segments.first?.color?.toHex(),
            preset: nil
        )
    }
}

extension Device {
    // MARK: Computed values
    
    /// URL of the device
    var url: URL {
        URL(string: "http://\(address):\(port)")!
    }

    /// WLED api for the device
    var api: WLED {
        WLED(baseUrl: self.url)
    }
    
    /// SwiftUI Color instance for this device
    var actualColor: Color? {
        guard let color else { return nil }
        let uiColor = UIColor(hex: color)
        
        return Color(uiColor: uiColor)
    }
    
    // MARK: Functions
    
    func sendBrightness() async {
        await self.api.sendJSON(state: [ "bri": Int(self.brightness) ])
    }
    
    func sendPreset() async {
        guard let preset else { return }
        await self.api.setPreset(preset)
    }
}
