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
    
    func getInfo(address: String, port: String) async throws -> WLEDStateResponse {
        let data = try await AF.request("http://\(address):\(port)/json")
            .validate()
            .serializingDecodable(WLEDStateResponse.self)
            .value
        
        return data
    }
}
