//
//  ExploreArtist.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import SwiftUI

struct ExploreArtist: View {
    let author: Author
    var onProfileTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile Image and Name
            HStack(spacing: 8) {
                Image(author.profileImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40) // Smaller profile picture
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))

                Text(author.name)
                    .font(.subheadline)
                    .bold()
            }

            // Content Image
            Image(systemName: author.contentImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120) // Smaller content image
                .cornerRadius(8)
                .clipped()

            // Description
            Text(author.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2) // Reduced number of lines

            // Profile Button
            Button(action: onProfileTap) {
                Text("View Profile")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
        .padding(12) // Smaller padding
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Author Model
struct Author: Identifiable {
    let id: Int
    let profileImageName: String
    let name: String
    let contentImageName: String
    let description: String
}

