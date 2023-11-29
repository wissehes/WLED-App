//
//  WLEDState.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import Foundation
import UIKit

struct WLEDStateResponse: Codable {
    let state: WLEDState
    let info: WLEDInfo
    
    let effects: [String]
    let palettes: [String]
}

struct WLEDState: Codable {
    /// Whether the device is turned on
    let on: Bool
    /// Brightness as 1 - 255.
    /// If the device is off, this contains last brightness when light was on
    let brightness: Float
    let presetId: Int
    let playlistId: Int
    let segments: [Segment]
    
    struct Segment: Codable {
        /// Active color scheme in this palette
        let colors: [[Float]]
        
        var color: UIColor? {
            guard let colors = colors.first else { return nil }
            let red = CGFloat(colors[0])
            let green = CGFloat(colors[1])
            let blue = CGFloat(colors[2])
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        
        enum CodingKeys: String, CodingKey {
            case colors = "col"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case on         = "on"
        case brightness = "bri"
        case presetId   = "ps"
        case playlistId = "pl"
        case segments   = "seg"
    }
}

struct WLEDInfo: Codable {
    /// WLED Version name
    let version: String
    /// Friendly name of the light
    let name: String
    /// The UDP port for realtime packets and WLED broadcast.
    let udpPort: Int
    /// Whether the device is currently receiving realtime data via UDP
    let live: Bool
    /// Number of currently connected WebSockets clients.
    /// `-1` means this build does not supprt WebSockets.
    let ws: Int
    
    let fxcount, palcount, cpalcount: Int
    /// Name of the platform WLED is running on
    let arch: String
    /// Version of the underlying (Arduino core) SDK.
    let core: String
    /// Bytes of heap memory (RAM) currently available.
    let freeheap: Int
    /// Time since the last boot/reset in seconds.
    let uptime: Int
    let time: String
    let opt: Int
    /// The producer/vendor of the light.
    let brand: String
    /// The product name.
    let product: String
    /// The hexadecimal hardware MAC address of the light, lowercase and without colons.
    let mac: String
    /// The IP address of this instance.
    let ip: String
    
    /// The device's WiFi information
    let wifi: WiFi
    
    struct WiFi: Codable {
        /// The network's BSSID
        let bssid: String
        /// The RSSI level
        let rssi: Int
        /// Relative signal level from 0 - 100
        let signal: Int
        /// The network's WiFi channel
        let channel: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case version = "ver"
        case name
        case udpPort = "udpport"
        case live, ws, fxcount, palcount, cpalcount, arch, core
        case freeheap, uptime, time, opt, brand, product, mac, ip, wifi
    }
}
