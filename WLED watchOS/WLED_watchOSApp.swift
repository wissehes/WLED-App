//
//  WLED_watchOSApp.swift
//  WLED watchOS Watch App
//
//  Created by Wisse Hes on 04/12/2023.
//

import SwiftUI

@main
struct WLED_watchOS_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Device.self)
        }
    }
}
