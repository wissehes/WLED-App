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
    @State private var changeIconShowing = false
    
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
                .overlay {
                    if devices.isEmpty {
                        ContentUnavailableView {
                            Label("No devices added yet", systemImage: "lightbulb.min")
                        } actions: {
                            Button("Add devices") { addDevicesShowing.toggle() }
                                .buttonStyle(.bordered)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        menu
                    }
                }
                .task { await refreshAll() }
                .refreshable { await refreshAll() }
                .sheet(isPresented: $addDevicesShowing, content: {
                    DiscoverDevicesSheet()
                })
                .sheet(isPresented: $changeIconShowing, content: {
                    ChangeAppIconView()
                })
        } detail: {
            if let device = selectedDevice {
                DeviceWebView(device: device)
            } else {
                ContentUnavailableView("Select an item", systemImage: "network")
            }
        }
    }
    
    private func refreshAll() async {
        for device in devices {
            await device.update()
        }
    }
    
    private var menu: some View {
        Menu("Menu", systemImage: "ellipsis") {
            Button("Add devices", systemImage: "plus") {
                addDevicesShowing.toggle()
            }
            
            Button("Change icon", systemImage: "app.dashed") {
                changeIconShowing.toggle()
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
