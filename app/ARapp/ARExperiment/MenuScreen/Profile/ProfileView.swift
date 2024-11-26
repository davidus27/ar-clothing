//
//  ProfileView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI

struct ProfileView: View {
    @State private var isEditProfilePresented: Bool = false
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    @State private var name: String = "John Doe"
    @State private var description: String = "Creative designer with a passion for art and AR."
    
    var body: some View {
        VStack(spacing: 0) { // Zero spacing to tightly control layout
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    Image(systemName: "plus.square.on.square")
                        .font(.title) // Match the text size
                        .foregroundColor(.yellow)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                // Custom bounce effect
                            }
                        }
                }
            }
            
            // Dynamic Content
            ScrollView {
                NavigationView {
                    VStack(spacing: 20) {
                        // Profile Image
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .shadow(radius: 5)

                        // Profile Name
                        Text(name)
                            .font(.title)
                            .bold()

                        // Profile Description
                        Text(description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        Spacer()

                        // Edit Profile Navigation
                        NavigationLink(destination: EditProfilePage(
                            profileImage: $profileImage,
                            name: $name,
                            description: $description
                        )) {
                            Text("Edit Profile")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()

                        Spacer()
                    }
                    .padding()
//                    .navigationTitle("Profile")
                }

            }
        }
    }

}


#Preview {
    ProfileView()
}
