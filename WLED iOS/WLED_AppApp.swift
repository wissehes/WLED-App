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
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Device.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
