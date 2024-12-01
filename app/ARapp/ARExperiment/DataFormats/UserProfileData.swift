//
//  UserProfileData.swift
//  ARExperiment
//
//  Created by David Drobny on 30/11/2024.
//

struct UserProfileData: Codable {
    var id: String // Unique user ID
    var name: String
    var description: String
    var profileImageURL: String // URL to the profile image
}


struct LinkedClothingData: Codable, Identifiable {
    var id: String // Unique ID for the clothing
    var name: String
    var uid: String // Encoded UID of the clothing
}
