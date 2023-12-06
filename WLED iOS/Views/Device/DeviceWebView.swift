//
//  DeviceWebView.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import SwiftUI
import Starscream

struct DeviceWebView: View {
    var device: Device
    
    @State private var session: WebSocket?
    
    var body: some View {
        WebView(url: device.url)
            .navigationTitle(device.name)
            .navigationBarTitleDisplayMode(.inline)
            .task(id: device) {
                // Reset connection if the device changes
                self.session?.disconnect()
                self.initWS()
            }
            .onDisappear { self.session?.disconnect() }
    }
    
    // Connect via WebSockets so that the Device instance
    // stays up-to-date with the web interface
    private func initWS() {
        let wsURL = URL(string: "ws://\(device.address):\(device.port)/ws")!
        let request = URLRequest(url: wsURL)
        
        self.session = WebSocket(request: request)
        
        self.session?.onEvent = self.eventHandler(for:)
        
        self.session?.connect()
    }
    
    private func eventHandler(for event: WebSocketEvent) -> Void {
        switch event {
        case .connected(_):
            print("WS Connected")
        case .text(let message):
            self.updateDevice(for: message)
            
        default:
            break;
        }
    }
    
    private func updateDevice(for message: String) {
        guard let data = message.data(using: .utf8) else { return }
        do {
            let decoded = try JSONDecoder().decode(WLEDStateResponse.self, from: data)
            withAnimation {
                self.device.update(response: decoded)
            }
        } catch {
            print("Decoding failed")
            print(error)
        }
    }
}

#Preview {
    let container = DataController.previewContainer
    
    let device = Device.exampleDevice()
    
    return NavigationStack {
        DeviceWebView(device: device)
            .modelContainer(container)
    }
}
