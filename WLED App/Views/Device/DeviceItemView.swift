//
//  DeviceItemView.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import SwiftUI

struct DeviceItemView: View {
    @State var device: Device

    init(device: Device) {
        self._device = .init(wrappedValue: device)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(device.name + (device.isOnline ? "" : " (Offline)"))
                    .font(.headline)
                Text(device.address)
            }
            
            Spacer()
            
            Toggle("Is on", isOn: $device.isPoweredOn)
                .labelsHidden()
        }.onChange(of: device.isPoweredOn) {
            Task { await device.setOnOff(state: device.isPoweredOn) }
        }
    }
}

//#Preview {
//    DeviceItemView()
//}
