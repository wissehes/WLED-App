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
                ForEach(actualDevices) { item in
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
                        ProgressView()
                    }
                }
                .onAppear {
                    self.discovery.start()
                }
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
