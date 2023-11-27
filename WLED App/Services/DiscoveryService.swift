//
//  DiscoveryService.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import Foundation
import Network

@Observable
final class DiscoveryService {
    private let browser: NWBrowser
    private let bonjour: NWBrowser.Descriptor
    
    var devices: [Device] = []
    
    init() {
        // Initialise bonjour descriptor
        self.bonjour = NWBrowser.Descriptor.bonjour(type: "_wled._tcp" , domain: "local.")
        
        // Set bonjour parameters
        let bonjourParams = NWParameters()
        bonjourParams.allowLocalEndpointReuse = true
        bonjourParams.acceptLocalOnly = true
        bonjourParams.allowFastOpen = true
        
        // Create browser
        self.browser = NWBrowser(for: bonjour, using: bonjourParams)
        
        // Set handlers
        self.browser.stateUpdateHandler = self.stateUpdateHandler
        self.browser.browseResultsChangedHandler = self.browseResultsChangedHandler
    }
    
    public func start() {
        self.browser.start(queue: DispatchQueue.main)
    }
    
    /// State update handler for `NWBrowser`
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
    
    /// Browse results change handler for `NWBrowser`
    private func browseResultsChangedHandler(
        _ newResults: Set<NWBrowser.Result>,
        _ changes: Set<NWBrowser.Result.Change>
    ) -> Void {
        print("[NWBRowser] Results changed")
        
        print("[NWBRowser] Found items:")
        for item in newResults {
            print("- " + item.endpoint.debugDescription)
        }
        
        
        for item in changes {
            guard case .added(let result) = item else { continue }
            guard case .service(let name, _, _, _) = result.endpoint else { continue }
            print("[NWBrowser] Attempting to connect to \(name)")
            
            let connection = NWConnection(to: result.endpoint, using: .tcp)
            connection.stateUpdateHandler = { newState in
                self.itemConnectionUpdatedHandler(newState, name: name, connection: connection)
            }
            connection.start(queue: .global())
        }
        
    }
    
    /// Connection update handler
    private func itemConnectionUpdatedHandler(_ state: NWConnection.State, name: String, connection: NWConnection) {
        print("State update for \(name)")
        // Make sure all values and cases are correct
        guard case .ready = state else { return }
        guard let endpoint = connection.currentPath?.remoteEndpoint else { return }
        guard case .hostPort(let host, let port) = endpoint else { return }
        
        // Format address
        let address = String(host.debugDescription.split(separator: "%")[0])
        
        print("[NWBRowser] Connected to \(name) (\(address):\(port))")

        // Add the device
        let newDevice = Device(address: address, port: "\(port)", name: name)
        self.devices.append(newDevice)
    }
}
