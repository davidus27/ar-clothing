//
//  SettingsView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = false
    @State private var username: String = "John Doe"
    @State private var appVersion: String = "1.0.0"
    @State private var feedbackMessage: String = ""
    @Binding var activeTab: TabOption
    
    var body: some View {
        VStack(spacing: 0) { // Zero spacing to tightly control layout
            // Dynamic Content
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
                            print("Edit Profile tapped")
                            // move to the Profile
                            activeTab = .profile
                            
                        }) {
                            Text("Edit Profile")
                        }
                    
                        Button(action: {
                            print("Sign Out tapped")
                            // Add sign-out logic here
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
                        .onChange(of: notificationsEnabled) {
                        }
                        
                        Toggle(isOn: $darkModeEnabled) {
                            Text("Dark Mode")
                        }
                        .onChange(of: darkModeEnabled) {
                            print("Dark Mode enabled: \(darkModeEnabled)")
                        }
                    }
                    
                    // Support Section
                    Section(header: Text("Support")) {
                        Button(action: {
                            print("Send Feedback tapped")
                            // Open feedback form or logic to send feedback
                        }) {
                            Text("Send Feedback")
                        }
                        
                        Button(action: {
                            print("Help & FAQs tapped")
                            // Open Help & FAQs screen
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
                            print("Terms & Conditions tapped")
                            // Open Terms & Conditions screen
                        }) {
                            Text("Terms & Conditions")
                        }
                        
                        Button(action: {
                            print("Privacy Policy tapped")
                            // Open Privacy Policy screen
                        }) {
                            Text("Privacy Policy")
                        }
                    }
                }
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .listStyle(GroupedListStyle())
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
