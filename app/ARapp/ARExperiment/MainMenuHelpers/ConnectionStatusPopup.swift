//
//  ConnectionStatusPopup.swift
//  ARExperiment
//
//  Created by David Drobny on 09/12/2024.
//

import SwiftUI
import Foundation


struct ConnectionStatusPopupView: View {
    @State private var isVisible: Bool = false
    @State private var message: String = ""
    @State private var isSuccessful: Bool = true
    @EnvironmentObject var appStateStore: AppStateStore
    
    var body: some View {
        VStack {
            if isVisible {
                Text(message)
                    .font(.title2)
                    .padding()
                    .foregroundColor(.white)
                    .background(isSuccessful ? Color.green : Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: isVisible)
                    .padding(.top, 5) // Adjust based on your layout
                Spacer()
            }
        }.task {
            await checkConnection()
        }
        .padding()
    }
    

    func checkConnection() async {
        let address = appStateStore.state.externalSource + "/health"
        print("Checking connection to the server at \(address)")
        
        // Prepare the URL and request
         guard let url = URL(string: address) else {
            // If URL is invalid, immediately return
            message = "Failed to create a valid URL"
            isSuccessful = false
            isVisible = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Using GET request to check the server status
        
        do {
            // Perform the network call
            let (_, response) = try await URLSession.shared.data(for: request)
            
            // Check if the server responded correctly (status code 200)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Assuming the server sends a response in JSON format
                message = "Online connection complete"
                isSuccessful = true
            } else {
                // If the status code is not 200
                message = "Failed to connect to the server (status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode)))"
                isSuccessful = false
            }
            
        } catch {
            // Catch any errors (e.g., no internet, server not reachable)
            message = "Failed to connect to the server: \(error.localizedDescription)"
            isSuccessful = false
        }
        
        isVisible = true
        
        // Automatically hide the popup after 5 seconds
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        // Hide the popup
        withAnimation {
            isVisible = false
        }
    }

    
    func checkConnectionFake() async {
        print("AAAAhhhhh")
        // Simulating a network call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Replace with real API call
        
        isVisible = true
        
        let isConnected = Bool.random() // Replace with real connection logic
        message = isConnected ? "Online connection complete" : "Failed to connect to the server"
        isSuccessful = isConnected
        
        // Automatically hide the popup after 3 seconds
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        withAnimation {
            isVisible = false
        }
    }
}
