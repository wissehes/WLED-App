//
//  ContentView.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Query private var devices: [Device]
    
    @State private var selectedDevice: Device?
    @State private var addDevicesShowing = false
    @State private var isOn = false
    
    var body: some View {
        // TODO: Seperate these views into their own file
        NavigationSplitView {
            List(selection: $selectedDevice) {
                ForEach(devices) { device in
                    DeviceItemView(device: device)
                        .tag(device)
                }
            }.navigationTitle("Devices")
                .animation(.easeInOut, value: devices)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add devices", systemImage: "plus") {
                            addDevicesShowing.toggle()
                        }
                    }
                }
                .task {
                    for device in devices {
                        await device.update()
                    }
                }
                .sheet(isPresented: $addDevicesShowing, content: {
                    DiscoverDevicesSheet()
                })
        } detail: {
            if let device = selectedDevice {
                DeviceWebView(device: device)
            } else {
                ContentUnavailableView("Select an item", systemImage: "network")
            }
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Device.self
        ])
}
