//
//  LinkClothingView.swift
//  ARExperiment
//
//  Created by David Drobny on 30/11/2024.
//

import SwiftUI
import AVFoundation


import SwiftUI

struct LinkClothingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var linkedClothing: [LinkedGarmentData]
    @State private var scannedUID: String = ""
    @State private var garmentName: String = ""
    @State private var validationMessage: String = ""
    @State private var isSaving: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        VStack {
            Text("Scan QR Code")
                .font(.title)
                .padding()

            // Conditional scanner view
            if ProcessInfo.processInfo.isMacCatalystApp || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                QRCodeScannerViewMockup { scannedCode in
                    scannedUID = scannedCode
                    validationMessage = validateQRCode(scannedCode)
                }
                .frame(height: 300)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            } else {
                QRCodeScannerView { scannedCode in
                    scannedUID = scannedCode
                    validationMessage = validateQRCode(scannedCode)
                }
                .frame(height: 300)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            }

            // Validation message
            Text(validationMessage)
                .foregroundColor(validationMessage.contains("Invalid") ? .red : .green)
                .font(.caption)
                .padding(.bottom, 5)

            TextField("Enter Garment Name", text: $garmentName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if isSaving {
                ProgressView("Saving...")
                    .padding()
            } else {
                Button(action: saveLinkedClothingMockup) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(scannedUID.isEmpty || garmentName.isEmpty || validationMessage.contains("Invalid") ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(scannedUID.isEmpty || garmentName.isEmpty || validationMessage.contains("Invalid"))
                .padding()
            }

            if showError {
                Text("Error: \(validationMessage)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
        .padding()
    }

    /// Validate QR code format
    func validateQRCode(_ code: String) -> String {
        let pattern = #"^(je|pe|cc):[a-zA-Z0-9]{12}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        if let regex = regex, regex.firstMatch(in: code, range: NSRange(code.startIndex..., in: code)) != nil {
            return "Valid QR code"
        }
        return "Invalid QR code format"
    }

    /// Save linked clothing to the backend
    func saveLinkedClothing() {
        isSaving = true
        showError = false

        // Prepare payload
        let payload = ["name": garmentName, "uid": scannedUID]

        guard let url = URL(string: "https://example.com/api/link-clothing") else {
            validationMessage = "Invalid backend URL"
            isSaving = false
            showError = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSaving = false

                if let error = error {
                    validationMessage = "Error: \(error.localizedDescription)"
                    showError = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    validationMessage = "Unexpected server response"
                    showError = true
                    return
                }

                if httpResponse.statusCode == 200 {
                    // Success: Add clothing and dismiss view
                    linkedClothing.append(LinkedGarmentData(id: scannedUID, name: garmentName, uid: scannedUID))
                    dismiss()
                } else {
                    // Parse error message from response
                    if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                       let errorMessage = responseDict["error"] {
                        validationMessage = errorMessage
                    } else {
                        validationMessage = "Unexpected error occurred"
                    }
                    showError = true
                }
            }
        }.resume()
    }
    
    func saveLinkedClothingMockup() {
        isSaving = true
        showError = false

        // Simulate a 0.5-second delay before successful response
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.async {
                // Simulate a successful response
                isSaving = false
                linkedClothing.append(LinkedGarmentData(id: scannedUID, name: garmentName, uid: scannedUID))
                dismiss()  // Close the view after successful save
            }
        }
    }

}
