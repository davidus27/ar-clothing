//
//  SettingsView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = false
    @State private var username: String = "John Doe"
    @State private var appVersion: String = "1.0.0"
    @State private var feedbackMessage: String = ""

    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section(header: Text("Account")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(username)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // Logic for editing profile
                    }) {
                        Text("Edit Profile")
                    }
                    
                    Button(action: {
                        // Logic for signing out
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
                
                // Preferences Section
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                    }
                    
                    Toggle(isOn: $darkModeEnabled) {
                        Text("Dark Mode")
                    }
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    Button(action: {
                        // Logic to handle sending feedback
                    }) {
                        Text("Send Feedback")
                    }
                    
                    Button(action: {
                        // Logic to view help or FAQs
                    }) {
                        Text("Help & FAQs")
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // Logic to open Terms & Conditions
                    }) {
                        Text("Terms & Conditions")
                    }
                    
                    Button(action: {
                        // Logic to open Privacy Policy
                    }) {
                        Text("Privacy Policy")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}


#Preview {
    SettingsView()
}
