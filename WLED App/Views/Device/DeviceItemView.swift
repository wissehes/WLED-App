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
    
    var textColor: Color {
        if device.isPoweredOn {
            return device.actualColor ?? .primary
        } else {
            return .primary
        }
    }
    
    var brightnessPct: String {
        let fraction = device.brightness / 255
        return fraction.formatted(.percent.precision(.fractionLength(0)))
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 7.5) {
                Text(device.name + (device.isOnline ? "" : " (Offline)"))
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .animation(.smooth, value: textColor)
                
                HStack(alignment: .center, spacing: 20) {
                    HStack(alignment: .center, spacing: 5) {
                        Image(systemName: device.isPoweredOn ? "lightbulb.fill" : "lightbulb")
                            .contentTransition(.symbolEffect(.replace.downUp))
                            .bold()

                        Text(brightnessPct)
                            .font(.system(size: 15))
                            .contentTransition(.numericText())
                    }
                    
                    if let preset = device.preset {
                        HStack(spacing: 5) {
                            Image(systemName: "list.bullet")
                                .bold()
                            Text(preset.name)
                                .font(.system(size: 15))
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Spacer()
            
            Toggle("Is on", isOn: $device.isPoweredOn)
                .labelsHidden()
        }.tint(device.actualColor)
            .disabled(!device.isOnline)
        .contextMenu {
            toggleButton
            copyAddressButton
            presetsMenu
            
            Divider()
            
            deleteButton
        }
        .swipeActions {
            deleteButton
        }
        .onChange(of: device.isPoweredOn) {
            Task { await device.setOnOff(state: device.isPoweredOn) }
        }
        .onChange(of: device.preset) {
            guard let preset = device.preset else { return }
            Task {
                await device.api.setPreset(preset)
                await device.update()
            }
        }
    }
    
    var deleteButton: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            modelContext.delete(device)
        }
    }
    
    var toggleButton: some View {
        Button("Toggle device", systemImage: "power") {
            device.isPoweredOn.toggle()
        }
    }
    
    var copyAddressButton: some View {
        Button("Copy address", systemImage: "link") {
            UIPasteboard.general.string = device.url.absoluteString
        }
    }
    
    var presetsMenu: some View {
        Picker("Preset", selection: $device.preset) {
            Text("None")
                .italic()
                .tag(nil as Optional<WLEDPreset.Normalized>)
            
            ForEach(device.presets) { preset in
                MenuItem(preset: preset, isSelected: device.preset == preset)
                    .tag(preset as Optional<WLEDPreset.Normalized>)
            }
        }
    }
    
    struct MenuItem: View {
        var preset: WLEDPreset.Normalized
        var isSelected: Bool
        
        var color: Color? {
            guard let hex = preset.color else { return nil }
            let uiColor = UIColor(hex: hex)
            return Color(uiColor: uiColor)
        }
        
        var body: some View {
            HStack(alignment: .center) {
                Text(preset.name)
                Spacer()
                Image(systemName: "lightbulb")
                    .symbolVariant(isSelected ? .fill : .none)
                    .foregroundStyle(self.color ?? .accentColor)
            }
        }
    }
}

//#Preview {
//    DeviceItemView()
//}

#Preview {
    ContentView()
        .modelContainer(for: [
            Device.self
        ])
}
