//
//  DeviceInfoTabItem.swift
//  WLED Watch App
//
//  Created by Wisse Hes on 07/12/2023.
//

import SwiftUI

struct DeviceInfoTabItem: View {
    var info: WLEDInfo
    
    let secondsFormatter: DateComponentsFormatter = {
       let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    private func infoItem(label: String, value: String?) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .bold()
            Text(value ?? "Loading...")
        }
    }
    
    var body: some View {
        List {
            infoItem(label: "Device name", value: info.name)
            
            infoItem(label: "WLED Version", value: info.version)
            
            infoItem(label: "Uptime", value: secondsFormatter.string(from: TimeInterval(info.uptime)))
        }
        .navigationTitle("Info")
    }
}

//#Preview {
//    DeviceInfoTabItem()
//}
