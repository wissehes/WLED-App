//
//  DiscoverDevicesSheet.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import SwiftUI
import SwiftData

struct DiscoverDevicesSheet: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var devices: [Device]
    
    @State private var discovery = DiscoveryService()
    
    // Make sure added devices don't show here
    var actualDevices: [Device] {
        discovery.devices.filter { device in
            !devices.contains { $0.macAddress == device.macAddress }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                Section("Manually add a device") {
                    AddDeviceForm()
                }
                
                Section("Discovered devices") {
                    ForEach(actualDevices, content: deviceItem)
                    
                    if actualDevices.isEmpty {
                        ContentUnavailableView(
                            "No devices found",
                            systemImage: "magnifyingglass",
                            description: Text("Devices that you've already added won't appear here.")
                        ).padding()
                    }
                }
            }.navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.inline)
                .animation(.easeInOut, value: actualDevices)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Image(systemName: "magnifyingglass")
                            .symbolEffect(.pulse)
                    }
                }
                .onAppear {
                    self.discovery.start()
                }
        }
    }
    
    private func deviceItem(_ item: Device) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(item.name)
                    .bold()
                Text(item.address)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button("Add") { addDevice(item) }
        }
    }
    
    private func addDevice(_ device: Device) {
        modelContext.insert(device)
    }
}

#Preview {
    DiscoverDevicesSheet()
        .modelContainer(for: [Device.self])
}
