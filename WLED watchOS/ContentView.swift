//
//  ContentView.swift
//  WLED watchOS Watch App
//
//  Created by Wisse Hes on 04/12/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Query private var devices: [Device]
    
    @State private var selectedDevice: Device?
    @State private var discoverSheetShowing = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDevice) {
                ForEach(devices) { device in
                    DeviceListView(device: device)
                    .tag(device)
                    .onTapGesture {
                        selectedDevice = device
                    }
                }
            }
            .navigationTitle("WLED")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await updateDevices()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Discover devices", systemImage: "plus") {
                        discoverSheetShowing.toggle()
                    }
                }
            }
            .sheet(isPresented: $discoverSheetShowing, content: DiscoverDevicesSheet.init)
            .overlay {
                if devices.isEmpty {
                    ContentUnavailableView("No devices", systemImage: "lightbulb.min.badge.exclamationmark")
                }
            }
        } detail: {
            if let selectedDevice {
                DeviceItemView(device: selectedDevice)
            } else {
                Text("Select a device")
            }
        }
        
    }
    
    private func updateDevices() async {
        for device in devices {
            await device.update()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataController.previewContainer)
}
