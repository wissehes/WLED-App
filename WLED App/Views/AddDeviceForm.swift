//
//  AddDeviceForm.swift
//  WLED App
//
//  Created by Wisse Hes on 29/11/2023.
//

import SwiftUI
import SwiftData
import Alamofire

enum AddDevicError: Error, LocalizedError {
    case couldNotReachDevice
    case alreadyAdded(Device?)
    case notAWLEDDevice
    
    var errorDescription: String? {
        switch self {
        case .couldNotReachDevice:
            return String(localized: "Could not reach the device")
        case .alreadyAdded(_):
            return String(localized: "This device has already been added.")
        case .notAWLEDDevice:
            return String(localized: "This isn't a WLED device.")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .couldNotReachDevice, .notAWLEDDevice:
            return String(localized: "Double check the IP address and make sure the light is turned on.")
        default:
            return nil
        }
    }
}

struct AddDeviceForm: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var addedDevices: [Device]
    
    @State private var isLoading = false
    @State private var deviceError: AddDevicError?
    @State private var errorShowing = false
    
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
                Button {
                    Task { await self.addDevice() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Label("Add", systemImage: "plus")
                    }
                }.buttonStyle(.bordered)
                    .hoverEffect(.lift)
                    .disabled(isDisabled)
                    .animation(.bouncy, value: isLoading)
            }
        }.alert(isPresented: $errorShowing, error: deviceError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    /// Tries to connect with the device and then adds it
    @MainActor private func addDevice() async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        let api = WLED(address: address, port: "80")
        guard let api else { return }

        
        do {
            let info = try await api.getInfo()
            let device = Device(wled: info)
            
            if let addedDevice = addedDevices.first(where: { $0.address == device.address }) {
                throw AddDevicError.alreadyAdded(addedDevice)
            } else {
                modelContext.insert(device)
                dismiss()
            }
            
        } catch let error as AddDevicError  {
            self.deviceError = error
            self.errorShowing = true
        } catch let error as AFError {
            if case .responseSerializationFailed = error {
                self.deviceError = .notAWLEDDevice
            } else {
                self.deviceError = .couldNotReachDevice
            }
            self.errorShowing = true
        } catch {
            self.deviceError = .couldNotReachDevice
            self.errorShowing = true
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
        .modelContainer(for: Device.self)
}
