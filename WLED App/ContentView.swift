//
//  ContentView.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var addDevicesShowing = false
    
    var body: some View {
        NavigationSplitView {
            List {
                Button("Add devices") {
                    addDevicesShowing.toggle()
                }
            }.sheet(isPresented: $addDevicesShowing, content: {
                DiscoverDevicesSheet()
            })
        } detail: {
            // Detail view
            ContentUnavailableView("Select an item", systemImage: "network")
        }

    }
}

#Preview {
    ContentView()
}
