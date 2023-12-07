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
    @State private var info: WLEDInfo?
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
            .navigationTitle(device.name)
            .tag(1)
            
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
            .navigationTitle("Settings")
            .tag(2)
            
            if let info {
                DeviceInfoTabItem(info: info)
                    .tag(3)
            }
        }
        .tabViewStyle(.carousel)
        .containerBackground(background, for: .navigation)
        .animation(.easeInOut, value: background)
        .task { await self.load() }
        .onChange(of: device.isPoweredOn) {
            Task { await device.setOnOff(state: device.isPoweredOn) }
        }
        .onChange(of: device.brightness) {
            Task { await device.sendBrightness() }
        }
        .onChange(of: device.preset) {
            Task { await device.sendPreset() }
        }
        .onChange(of: device.isSyncSend) {
            Task { await device.sendUDPSend() }
        }
    }
    
    @MainActor
    private func load() async {
        do {
            let data = try await device.api.getInfo()
            withAnimation {
                self.info = data.info
            }
            
            device.update(response: data)
        } catch {
            print("Loading failed: ")
            print(error)
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
