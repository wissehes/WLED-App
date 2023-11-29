//
//  AddDeviceForm.swift
//  WLED App
//
//  Created by Wisse Hes on 29/11/2023.
//

import SwiftUI

struct AddDeviceForm: View {
    
    @State private var name = ""
    @State private var address = ""
    
    var isDisabled: Bool {
        address.isEmpty || name.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Name", text: $name)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 7.5)
                        .stroke(.secondary.opacity(0.5), lineWidth: 1)
                )
            
            TextField("IP Address", text: $address)
                .keyboardType(.numbersAndPunctuation)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 7.5)
                        .stroke(.secondary.opacity(0.5), lineWidth: 1)
                )
            
            HStack {
                Button("Add", systemImage: "plus") { }
                    .buttonStyle(.bordered)
                    .hoverEffect(.lift)
                    .disabled(isDisabled)
            }
        }
    }
    
    struct Preview: View {
        @State private var isOpened = true
        
        var body: some View {
            HStack {
                Text("Hi!")
            }
                .sheet(isPresented: $isOpened) {
                    List {
                        Section("Add device") {
                            AddDeviceForm()
                        }
                    }
                }
        }
    }
}

#Preview {
    AddDeviceForm.Preview()
}
