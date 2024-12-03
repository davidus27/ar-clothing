//
//  ProfileContent.swift
//  ARExperiment
//
//  Created by David Drobny on 03/12/2024.
//

import SwiftUI

struct ProfileContent: View {
    let profile: UserData
    let profileImage: Image

    var body: some View {
        VStack {
            profileImage
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))

            Text(profile.name)
                .font(.title)
                .bold()

            Text(profile.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
    }
}
