//
//  ProfileView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI


struct ProfileView: View {
//    @State private var profileData: ProfileData? = nil // Holds the profile data after loading
    @StateObject var profileStore = UserDataStore()
    @State private var isLoading: Bool = true         // Tracks the loading state
    @State private var isEditProfilePresented: Bool = false
    @State private var linkedClothing: [LinkedClothingData] = [] // Holds linked garments
    @State private var isLinkClothingPresented: Bool = false // Toggles the QR code scanning page

    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Profile")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()

                    Image(systemName: "plus.square.on.square")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
            }
            
            // Dynamic Content
            if isLoading {
                ProgressView("Loading Profile...")
                    .padding()
            } else if let profile = profileStore.user {
                NavigationView {
                    VStack(spacing: 20) {
                        // Profile Image
                        profileStore.decodedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .shadow(radius: 5)
                        
                        // Profile Name
                        Text(profile.name)
                            .font(.title)
                            .bold()
                        
                        // Profile Description
                        Text(profile.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        // Edit Profile Navigation
                        NavigationLink(destination: EditProfilePage(
                            profileImage: .constant(profileStore.decodedImage),
                            name: .constant(profile.name),
                            description: .constant(profile.description)
                        )) {
                            Text("Edit Profile")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()

                        // Linked Clothing Section
                        VStack(alignment: .leading) {
                            Text("Linked Clothing")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            if linkedClothing.isEmpty {
                                Text("No clothing linked yet.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(linkedClothing) { clothing in
                                    HStack {
                                        Text(clothing.name)
                                            .font(.body)
                                        Spacer()
                                        Text(clothing.uid)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            
                            Button(action: {
                                isLinkClothingPresented = true
                            }) {
                                Text("Link New Clothing")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                Text("Failed to load profile data.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $isLinkClothingPresented) {
            LinkClothingView(linkedClothing: $linkedClothing)
        }
        .onAppear {
            loadProfileData()
        }
    }

    /// Function to simulate fetching profile data from the backend
    private func loadProfileData() {
        isLoading = true
        Task {
            do {
                // Simulated delay for loading data
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                profileStore.fetchMockupData()
                
                isLoading = false
            }
        }
    }
}

/// Represents the profile data fetched from the server
//struct ProfileData {
//    let image: Image
//    let name: String
//    let description: String
//    let joinedDate: String
//}
