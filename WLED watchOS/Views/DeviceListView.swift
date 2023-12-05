//
//  DeviceListView.swift
//  WLED Watch App
//
//  Created by Wisse Hes on 05/12/2023.
//

import SwiftUI

struct DeviceListView: View {
    
    @State private var device: Device

    init(device: Device) {
        self._device = .init(wrappedValue: device)
    }
    
    var iconColor: Color {
        if let color = device.actualColor, device.isPoweredOn {
            return color
        } else {
            return .primary
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Text(device.name)
                .bold()
            
            Spacer()
            
            Image(systemName: "lightbulb")
                .symbolVariant(device.isPoweredOn ? .fill : .none)
                .contentTransition(.symbolEffect(.replace.downUp))
                .foregroundStyle(iconColor)
            
            Toggle("Device state", isOn: $device.isPoweredOn)
                .labelsHidden()
        }.onChange(of: device.isPoweredOn) {
            Task { await device.setOnOff(state: device.isPoweredOn) }
        }
    }
}

#Preview {
    let container = DataController.previewContainer

    let device = Device(
        address: "192.168.178.113",
        macAddress: nil,
        port: nil,
        name: nil,
        presets: [
            .init(name: "Normal", id: "1", color: nil)
        ],
        isOnline: true,
        isPoweredOn: true,
        brightness: 255,
        color: nil,
        preset: nil
    )
    
    return List {
        DeviceListView(device: device)
    }.modelContainer(container)
}
