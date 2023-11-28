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
    
    @State private var addDevicesShowing = false
    @State private var isOn = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(devices) { device in
                    DeviceItemView(device: device)
                }
            }.navigationTitle("Devices")
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
            // Detail view
            ContentUnavailableView("Select an item", systemImage: "network")
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Device.self
        ])
}
