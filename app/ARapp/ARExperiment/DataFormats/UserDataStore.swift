//
//  GlobalValues.swift
//  ARExperiment
//
//  Created by David Drobny on 30/11/2024.
//

import SwiftUI
import Combine

struct LinkedGarmentData: Codable, Identifiable {
    var id: String // Unique ID for the clothing
    var name: String
    var uid: String // Encoded UID of the clothing
}
        
// UserData structure conforms to Codable and ObservableObject
struct UserData: Identifiable, Codable {
    var id: String
    var imageBase64: String? // URL or path to the image
    var name: String
    var description: String
    var joinedDate: String
    
    static let mockupUser = UserData(
        id: "0",
        imageBase64: "",
        name: "Loading...",
        description: "Fetching your profile details...",
        joinedDate: ""
    )
}

class UserDataStore: ObservableObject {
    @Published var user: UserData?
    @Published var linkedGarments: [LinkedGarmentData] = []
    
    public var didFail: Bool = false
    public var decodedImage: Image = Image(systemName: "exclamationmark.icloud.fill")
    
    // Example function for fetching user data from a REST API
    func fetchUserData() {
        // Assume we have an API URL
        guard let url = URL(string: "http://192.168.1.19:8000/users/674edb056dbea5d239033941") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            // if error occurs store it in error
            if error != nil {
                self?.didFail = true
            }
            
            guard let data = data, error == nil else { return }
            
            print("data: \(data)")
            
            // Decode JSON into UserData
            let decoder = JSONDecoder()
            if let userData = try? decoder.decode(UserData.self, from: data) {
                DispatchQueue.main.async {
                    self?.user = userData
                }
            }
        }.resume()
        
        decodedImage = getImage(base64String: user?.imageBase64 ?? getBase64ImageValue(image: UIImage(systemName: "person.crop.circle.fill")!))
    }
    
    func fetchMockupData() {
        user = UserData(
            id: "mockUser123", // Unique ID for the mock data
            imageBase64: getBase64ImageValue(image: UIImage(systemName: "person.crop.circle.fill")!), // base-64
            name: "John Doe",
            description: "Creative designer with a passion for art and AR.",
            joinedDate: "01/01/24"
        )
        
        linkedGarments = [
            LinkedGarmentData(id: "1", name: "T-Shirt", uid: "je:asdiuasibd"),
            LinkedGarmentData(id: "2", name: "Jeans", uid: "je:daiosubdob"),
            LinkedGarmentData(id: "3", name: "Jacket", uid: "pe:jabsbdiasbd")

        ]
        
        decodedImage = getImage(base64String: user!.imageBase64!)
    }
    
    func getImage(base64String: String) -> Image {
        // Decode the Base64 string into Data
        guard let imageData = Data(base64Encoded: base64String) else {
            fatalError("Failed to decode Base64 string")
            
        }
        
        // Create a UIImage from the data
        guard let uiImage = UIImage(data: imageData) else {
            fatalError("Failed to create UIImage from data")
        }
        
        // Convert UIImage to SwiftUI Image
        let image = Image(uiImage: uiImage)
        return image
    }

}
