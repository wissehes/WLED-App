//
//  DeviceItemView.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import SwiftUI

struct DeviceItemView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var device: Device

    init(device: Device) {
        self._device = .init(wrappedValue: device)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(device.name + (device.isOnline ? "" : " (Offline)"))
                    .font(.headline)
                    .foregroundStyle(device.actualColor ?? .white)
                Text(device.address)
            }
            
            Spacer()
            
            Toggle("Is on", isOn: $device.isPoweredOn)
                .labelsHidden()
        }.tint(device.actualColor)
        .contextMenu {
            deleteButton
        }
        .swipeActions {
            deleteButton
        }
        .onChange(of: device.isPoweredOn) {
            Task { await device.setOnOff(state: device.isPoweredOn) }
        }
    }
    
    var deleteButton: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            modelContext.delete(device)
        }
    }
}

//#Preview {
//    DeviceItemView()
//}
