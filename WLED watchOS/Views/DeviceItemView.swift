//
//  DeviceItemView.swift
//  WLED Watch App
//
//  Created by Wisse Hes on 04/12/2023.
//

import SwiftUI

struct DeviceItemView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var device: Device
    @State private var tab: Int = 1
    
    init(device: Device) {
        self._device = .init(wrappedValue: device)
    }
    
    var background: AnyGradient {
        if device.isPoweredOn {
            return device.actualColor?.gradient ?? Color.green.gradient
        } else {
            return Color.accentColor.gradient
        }
    }
    
    var body: some View {
        TabView(selection: $tab) {
            VStack {
                Button {
                    device.isPoweredOn.toggle()
                } label: {
                    Label("Toggle light", systemImage: "power")
                        .labelStyle(.iconOnly)
                        .bold()
                }.font(.system(size: 60))
                    .buttonStyle(.plain)
                    .foregroundStyle(device.isPoweredOn ? .green : .secondary)
                
                Slider(value: $device.brightness, in: 0...255, step: 255 * 0.10 ) {
                    Label("Brightness", systemImage: "light.max")
                }
            }
            .tag(1)
            
            NavigationStack {
                List {
                    Picker(selection: $device.preset) {
                        Text("None").tag(nil as WLEDPreset.Normalized?)
                        ForEach(device.presets) { preset in
                            Text(preset.name)
                                .tag(preset as WLEDPreset.Normalized?)
                        }
                        
                    } label: {
                        Label("Preset", systemImage: "list.bullet")
                    }
                    
                    Toggle("Sync", systemImage: "arrow.triangle.2.circlepath", isOn: $device.isSyncSend)
                }
            }.tag(2)
        }.navigationTitle(device.name)
            .tabViewStyle(.carousel)
            .containerBackground(background, for: .navigation)
            .animation(.easeInOut, value: background)
            .task { await device.update() }
            .onChange(of: device.isPoweredOn) {
                Task { await device.setOnOff(state: device.isPoweredOn) }
            }
            .onChange(of: device.brightness) {
                Task { await device.sendBrightness() }
            }
    }
}

#Preview {
    let container = DataController.previewContainer
    
    return NavigationStack {
        DeviceItemView(device: Device.exampleDevice())
            .modelContainer(container)
    }
}
