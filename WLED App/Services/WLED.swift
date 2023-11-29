//
//  WLED.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import Foundation
import Alamofire

class WLED {
    static let shared = WLED()
    
    /// Get the JSON state/info object from a device
    func getInfo(address: String, port: String) async throws -> WLEDStateResponse {
        let data = try await AF.request("http://\(address):\(port)/json")
            .validate()
            .serializingDecodable(WLEDStateResponse.self)
            .value
        
        return data
    }
    
    /// Set the on/off state of the device
    func setState(_ state: Bool, address: String, port: String) async {
        let body = [
            "on": state
        ]
        
        guard let url = URL(string: "http://\(address):\(port)/json") else { return }
        guard var request = try? URLRequest(url: url, method: .post) else { return }
        request.httpBody = try? JSONEncoder().encode(body)
        request.headers = [ .contentType("application/json") ]
        
        let _ = try? await URLSession.shared.data(for: request)
    }
}
