//
//  ProfileView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileStore: UserDataStore
    @EnvironmentObject var appStateStore: AppStateStore
    
    @State private var isLoading: Bool = true
    @State private var isEditProfilePresented: Bool = false
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
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .font(.title)
            } else if !profileStore.didFail {
                NavigationView {
                    VStack(spacing: 20) {
                        // Profile Image
//                        profileStore.decodedImage
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
//                            .shadow(radius: 5)
                        
                        profileStore.decodedImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())

                        
                        // Profile Name
                        Text(profileStore.user.name)
                            .font(.title)
                            .bold()
                        
                        // Profile Description
//                        Text(profile.description)
//                            .font(.body)
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.gray)
                        
                        Text(profileStore.user.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .lineLimit(3) // Limit to 3 lines
                            .truncationMode(.tail)
                        
                        // Edit Profile Navigation
                        NavigationLink(destination: EditProfilePage(
                            profileImage: .constant(profileStore.decodedImage),
                            name: .constant(profileStore.user.name),
                            description: .constant(profileStore.user.description)
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
                            
                            
                            if profileStore.user.garments.isEmpty {
                                Text("No clothing linked yet.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(profileStore.user.garments) { clothing in
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
            LinkClothingView().environmentObject(profileStore)
        }
        .onAppear {
            if !profileStore.isLoaded && !profileStore.didFail {
                loadProfileData()
            }
        }
    }

    /// Function to simulate fetching profile data from the backend
    private func loadProfileData() {
        Task {
            do {
                profileStore.fetchUserData(urlAddress: appStateStore.userAddress)
                isLoading = false
            }
        }
    }
}
