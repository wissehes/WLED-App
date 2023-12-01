//
//  ChangeAppIconView.swift
//  WLED App
//
//  Created by Wisse Hes on 01/12/2023.
//

import SwiftUI

struct ChangeAppIconView: View {
    
    private var icons = AppIcon.allCases

    @Environment(\.dismiss) private var dismiss
    @State private var currentIcon: AppIcon
    
    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            _currentIcon = .init(initialValue: appIcon)
        } else {
            _currentIcon = .init(initialValue: .primary)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(icons) { icon in
                HStack {
                    Image(uiImage: icon.preview)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(.rect(cornerRadius: 12))
                    
                    Text(icon.description)
                        .bold()
                    
                    Spacer()
                    
                    if icon.id == currentIcon.id {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accentColor)
                    }
                }.onTapGesture {
                    updateIcon(to: icon)
                }
            }.navigationTitle("Change app icon")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
    
    func updateIcon(to icon: AppIcon) {
        guard UIApplication.shared.alternateIconName != icon.iconName else { return }
        
        Task { @MainActor in
            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
                currentIcon = icon
                dismiss()
            }
        }
    }
}

#Preview {
    ChangeAppIconView()
}
