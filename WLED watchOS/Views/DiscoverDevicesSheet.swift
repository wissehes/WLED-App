//
//  DiscoverDevicesSheet.swift
//  WLED Watch App
//
//  Created by Wisse Hes on 05/12/2023.
//

import SwiftUI
import SwiftData

struct DiscoverDevicesSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var discovery = DiscoveryService()
    
    var body: some View {
#if targetEnvironment(simulator)
        NavigationStack {
            List(discovery.devices, rowContent: AddDeviceItemView.init)
                .navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.large)
                .overlay {
                    if discovery.devices.isEmpty {
                        ProgressView()
                    }
                }
                .onAppear { discovery.start() }
        }
#else
        ContentUnavailableView(
            "Use the app on your phone to add devices",
            systemImage: "questionmark.circle"
        )
#endif
    }
    
    struct AddDeviceItemView: View {
        var device: Device
        
        init(_ device: Device) {
            self.device = device
        }
        
        @Query private var devices: [Device]
        @Environment(\.modelContext) private var modelContext
        
        var isAdded: Bool {
            devices.contains { $0.macAddress == device.macAddress }
        }
        
        var buttonIcon: String {
            isAdded ? "checkmark.circle" :"plus"
        }
        
        var body: some View {
            HStack {
                Text(device.name)
                
                Spacer()
                
                Button("Add", systemImage: buttonIcon) {
                    addDevice(self.device)
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.accent)
                .disabled(isAdded)
            }
        }
        
        private func addDevice(_ device: Device) {
            modelContext.insert(device)
        }
    }
}

#Preview {
    DiscoverDevicesSheet()
        .modelContainer(DataController.previewContainer)
}
