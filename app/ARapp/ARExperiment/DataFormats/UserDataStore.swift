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

struct Link: Codable {
    var rel: String
    var href: String
}
        
// UserData structure conforms to Codable and ObservableObject
struct UserData: Identifiable, Codable {
    var id: String
    var imageBase64: String?
    var name: String
    var description: String
    var joinedDate: String
    var garments: [LinkedGarmentData]
    var links: [Link]
    
    static let mockupUser = UserData(
        id: "0",
        imageBase64: "",
        name: "Loading...",
        description: "Fetching your profile details...",
        joinedDate: "",
        garments: [],
        links: []
    )
}

class UserDataStore: ObservableObject {
    @Published var user: UserData
    var isMockup: Bool = false
    var isLoaded: Bool = false
    
    init() {
        user = UserData.mockupUser
        isMockup = true
    }
    
    public var didFail: Bool = false
    public var decodedImage: Image = Image(systemName: "exclamationmark.icloud.fill")
    
    // Example function for fetching user data from a REST API
    func fetchUserData(urlAddress: String) {
        print("Starting to fetch user data")
        guard let url = URL(string: urlAddress) else {
            print("Invalid URL: \(urlAddress)")
            didFail = true
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching data: \(error.localizedDescription)")
                    self?.didFail = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received.")
                    self?.didFail = true
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let fetchedUser = try decoder.decode(UserData.self, from: data)
                DispatchQueue.main.async {
                    self?.user = fetchedUser
                    
                    // TODO: this inline handling should be done properly
                    self?.decodedImage = (fetchedUser.imageBase64 != nil) ? getImage(base64String: fetchedUser.imageBase64 ?? "") : Image(systemName: "person.crop.circle.fill")
                                        
                    self?.isLoaded = true
                    print("User data successfully loaded")
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error.localizedDescription)")
                    self?.didFail = true
                }
            }
        }.resume()
    }

    
    func fetchMockupData() {
        user = UserData(
            id: "mockUser123", // Unique ID for the mock data
            imageBase64: getBase64ImageValue(image: UIImage(systemName: "person.crop.circle.fill")!), // base-64
            name: "John Doe",
            description: "Creative designer with a passion for art and AR.",
            joinedDate: "01/01/24",
            garments: [
                LinkedGarmentData(id: "1", name: "T-Shirt", uid: "je:asdiuasibd"),
                LinkedGarmentData(id: "2", name: "Jeans", uid: "je:daiosubdob"),
                LinkedGarmentData(id: "3", name: "Jacket", uid: "pe:jabsbdiasbd")
            ],
            links: []
        )
        
        decodedImage = getImage(base64String: user.imageBase64!)
    }
}

