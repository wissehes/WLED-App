//
//  DataController.swift
//  WLED App
//
//  Created by Wisse Hes on 03/12/2023.
//

import Foundation
import SwiftData

@MainActor
class DataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Device.self, configurations: config)
            
            let device = Device(
                address: "192.168.178.113",
                macAddress: nil,
                port: nil,
                name: nil,
                presets: [],
                isOnline: true,
                isPoweredOn: true,
                brightness: 255,
                color: nil,
                preset: nil
            )
            container.mainContext.insert(device)
            
            return container
            
        } catch {
            fatalError("Failed to create a model container for previewing. \(error.localizedDescription)")
        }
    }()
}
