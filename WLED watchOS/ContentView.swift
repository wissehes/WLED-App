//
//  ContentView.swift
//  WLED watchOS Watch App
//
//  Created by Wisse Hes on 04/12/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Query var devices: [Device]
    
    @State var selectedDevice: Device?
    
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
            }.task {
                await updateDevices()
            }.overlay {
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
