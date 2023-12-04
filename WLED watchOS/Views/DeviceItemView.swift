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
    
    @State private var brightnessSheetShowing = false

    init(device: Device) {
        self._device = .init(wrappedValue: device)
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
                Slider(value: $device.brightness, in: 1...255, step: 255 * 0.10 ) {
                    Label("Brightness", systemImage: "light.max")
                }
            }.tag(1)
            
            NavigationStack {
                Picker(selection: $device.preset) {
                    Text("None").tag(nil as WLEDPreset.Normalized?)
                    ForEach(device.presets) { preset in
                        Text(preset.name)
                            .tag(preset as WLEDPreset.Normalized?)
                    }
                } label: {
                    Label("Preset", systemImage: "list.bullet")
                }

            }.tag(2)
        }.navigationTitle(device.name)
            .tabViewStyle(.carousel)
            .onChange(of: device.isPoweredOn) {
                Task { await device.setOnOff(state: device.isPoweredOn) }
            }
            .onChange(of: device.brightness) {
                // TODO: Debounce value
                Task { await device.sendBrightness() }
            }
//            .toolbar {
//                toolbar
//            }
//            .sheet(isPresented: $brightnessSheetShowing) {
//                Slider(value: $device.brightness, in: 1...255, step: 255 * 0.10)
//                    .focusable(true)
//                    .digitalCrownRotation($device.brightness, from: 1.0, through: 255.0, by: 1)
//            }
    }
    
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack {
                Spacer()
                Button("Brightness", systemImage: "light.max") {
                    brightnessSheetShowing.toggle()
                }
            }
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
    
    return NavigationStack {
        DeviceItemView(device: device)
            .modelContainer(container)
    }
}
