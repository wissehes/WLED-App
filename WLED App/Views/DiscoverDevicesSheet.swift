//
//  DiscoverDevicesSheet.swift
//  WLED App
//
//  Created by Wisse Hes on 27/11/2023.
//

import SwiftUI

struct DiscoverDevicesSheet: View {
    
    private let discovery = DiscoveryService()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(discovery.devices) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text(item.address)
                    }
                }
            }.navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        ProgressView()
                    }
                }
                .onAppear {
                    self.discovery.start()
                }
        }
    }
}

#Preview {
    DiscoverDevicesSheet()
        .modelContainer(for: [Device.self])
}
