//
//  DeviceWebView.swift
//  WLED App
//
//  Created by Wisse Hes on 28/11/2023.
//

import SwiftUI

struct DeviceWebView: View {
    var device: Device
    
    var url: URL {
        URL(string: "http://\(device.address):\(device.port)")!
    }
    
    var body: some View {
        WebView(url: url)
            .navigationTitle(device.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    DeviceWebView()
//}
