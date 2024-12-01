//
//  QRCodeScannerViewMockup.swift
//  ARExperiment
//
//  Created by David Drobny on 30/11/2024.
//

import SwiftUI

struct QRCodeScannerViewMockup: View {
    @State private var simulatedCode: String = "je:abcdefghijkl"
    var onSimulateCodeScanned: (String) -> Void = { _ in }

    var body: some View {
        VStack {
            Text("Mock QR Code Scanner")
                .font(.headline)
                .padding()

            // QR Code Frame
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 250, height: 250)
                    .background(Color.gray.opacity(0.2))

                Text("Simulated QR Code Frame")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()

            // Display the simulated code
            Text("Scanned Code: \(simulatedCode)")
                .font(.body)
                .padding()

            // Button to change the scanned value
            Button(action: {
                print("Generated code: \(simulatedCode)")
                onSimulateCodeScanned(simulatedCode) // Simulate the callback
            }) {
                Text("Simulate Scan")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}


#Preview {
    QRCodeScannerViewMockup()
}
