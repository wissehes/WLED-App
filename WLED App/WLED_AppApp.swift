//
//  WLED_AppApp.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import SwiftUI
import SwiftData

@main
struct WLED_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Device.self
                ])
        }
    }
}
