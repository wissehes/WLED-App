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
    
    /// Get the JSON state/info object from a device
    func getInfo() async throws -> WLEDStateResponse {
        let data = try await AF.request(jsonUrl)
            .validate()
            .serializingDecodable(WLEDStateResponse.self)
            .value
        
        return data
    }
    
    func getPresets() async throws -> [WLEDPreset.Normalized] {
        let data = try await AF.request(baseUrl.appending(path: "/presets.json"))
            .validate()
            .serializingDecodable(WLEDPresets.self)
            .value
        
        var items: [WLEDPreset.Normalized] = [];
        
        for (id, preset) in data {
            guard let normalized = WLEDPreset.Normalized(preset, id: id) else { continue }
            
            items.append(normalized)
        }
        
        items.sort { $0.id < $1.id }
        
        return items
    }
    
    /// Set the on/off state of the device
    func setState(_ state: Bool) async {
        let body = [
            "on": state
        ]
        
        guard var request = try? URLRequest(url: jsonUrl, method: .post) else { return }
        request.httpBody = try? JSONEncoder().encode(body)
        request.headers = [ .contentType("application/json") ]
        
        let _ = try? await URLSession.shared.data(for: request)
    }
}
