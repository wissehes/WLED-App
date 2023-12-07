//
//  WLED.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import Foundation
import Alamofire

class WLED {
    private var baseUrl: URL
    
    private var jsonUrl: URL {
        baseUrl.appending(path: "/json")
    }
    
    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
    
    init?(address: String, port: String) {
        guard let url = URL(string: "http://\(address):\(port)") else { return nil }
        self.baseUrl = url
    }
    
    /// Send JSON State to the device
    ///
    /// This sends the JSON State you supply to the device.
    /// See https://kno.wled.ge/interfaces/json-api/
    ///
    /// Note: This function ignores the response sent back by the API.
    ///
    /// - Parameters:
    ///     - state: The JSON State to send
    ///
    func sendJSON(state: Parameters) async {
        let _ = try? await AF.request(
            jsonUrl,
            method: .post,
            parameters: state,
            encoding: JSONEncoding.default
        )
            .serializingData()
            .value
    }
    
    /// Get the JSON state/info object from a device
    func getInfo() async throws -> WLEDStateResponse {
        let data = try await AF.request(jsonUrl)
            .validate()
            .serializingDecodable(WLEDStateResponse.self)
            .value
        
        return data
    }
    
    /// Get the presets from a device
    func getPresets() async throws -> [WLEDPreset.Normalized] {
        let data = try await AF.request(baseUrl.appending(path: "/presets.json"))
            .validate()
            .serializingDecodable(WLEDPresets.self)
            .value
        
        var items: [WLEDPreset.Normalized] = [];
        
        // Map presets to a normalized form
        for (id, preset) in data {
            guard let normalized = WLEDPreset.Normalized(preset, id: id) else { continue }
            
            items.append(normalized)
        }
        
        // Sort them by id
        items.sort { $0.id < $1.id }
        
        return items
    }
    
    /// Set the on/off state of the device
    func setState(_ state: Bool) async {
        let state = [
            "on": state
        ]
        
        await self.sendJSON(state: state)
    }
    
    /// Set the current preset
    func setPreset(_ preset: WLEDPreset.Normalized) async {
        let state: Parameters = [
            "ps": preset.id,
            "on": true
        ]
        
        await self.sendJSON(state: state)
    }
    
    /// Set the UDP send state
    func setUDPSend(_ state: Bool) async {
        let state: Parameters = [
            "udpn": [
                "send": state
            ]
        ]
        
        await self.sendJSON(state: state)
    }
}

//extension WLED {
//    class WSClient {
//        
//    }
//}
