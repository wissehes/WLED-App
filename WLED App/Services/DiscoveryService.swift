//
//  DiscoveryService.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import Foundation
import Network

final class DiscoveryService: ObservableObject {
    let browser: NWBrowser
    private let bonjour: NWBrowser.Descriptor
    
    init() {
        self.bonjour = NWBrowser.Descriptor.bonjour(type: "_wled._tcp" , domain: "local.")
        
        let bonjourParams = NWParameters()
        bonjourParams.allowLocalEndpointReuse = true
        bonjourParams.acceptLocalOnly = true
        bonjourParams.allowFastOpen = true
        
        self.browser = NWBrowser(for: bonjour, using: bonjourParams)
        
        self.browser.stateUpdateHandler = self.stateUpdateHandler
    }
    
    private func stateUpdateHandler(_ state: NWBrowser.State) -> Void {
        print("[NWBrowser] State updated: ")
        switch state {
        case .failed(let error):
            print("Error: \(error)")
            self.browser.cancel()
        case .ready:
            print("New bonjour discovery: ready")
        case .setup:
            print("SETUP State")
        default:
            break
        }
    }
}
