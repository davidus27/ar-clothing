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
    var animation_id: String
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
    var garments: [String]
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
    @Published var garments: [LinkedGarmentData] = []
    var address: String = ""
    var token: String = ""
    var user_id: String = ""
    
    init() {
        user = UserData.mockupUser
        isMockup = true
    }
    
    func setup(store: AppState) {
        self.address = store.externalSource
        self.token = store.authToken
        self.user_id = store.userId
    }
    
    public var didFail: Bool = false
    public var decodedImage: Image = Image(systemName: "exclamationmark.icloud.fill")
    
    // Example function for fetching user data from a REST API
    func fetchUserData(store: AppState) {
        setup(store: store)
        print("Setup done. Starting fetch.")

        fetchUser {
            print("Fetched user successfully")
            self.fetchGarments {
                print("Fetched garments successfully: \(self.garments)")
            }
        }
    }
    
    private func fetchUser(completion: @escaping () -> Void) {
        print("Starting to fetch user data")
        guard let url = URL(string: "\(self.address)/users/\(self.user_id)") else {
            print("Invalid URL: \(self.address)")
            didFail = true
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching data: \(error.localizedDescription)")
                    self?.didFail = true
                }
                completion()
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received.")
                    self?.didFail = true
                }
                completion()
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
            completion()
        }.resume()
    }
    
    private func fetchGarments(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(address)/garments/") else {
            print("Invalid URL for garments")
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching garments: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data received for garments")
                completion()
                return
            }
            
            do {
                if let garmentsArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.garments = garmentsArray.compactMap { garmentData in
                            guard
                                let id = garmentData["id"] as? String,
                                let name = garmentData["name"] as? String,
                                let uid = garmentData["uid"] as? String
                            else {
                                fatalError("Did not parse garment data correctly")
                            }
                            
                            let animation_id = (garmentData["animation_id"] as? String) ?? ""
                            
                            return LinkedGarmentData(id: id, name: name, uid: uid, animation_id: animation_id)
                        }
                    }
                } else {
                    print("Error: Data is not an array of animations.")
                }
                
            } catch {
                print("Error parsing JSON for garments: \(error.localizedDescription)")
            }
            completion()
        }.resume()
    }

    
    func fetchMockupData() {
        user = UserData(
            id: "mockUser123", // Unique ID for the mock data
            imageBase64: getBase64ImageValue(image: UIImage(systemName: "person.crop.circle.fill")!), // base-64
            name: "John Doe",
            description: "Creative designer with a passion for art and AR.",
            joinedDate: "01/01/24",
            garments: [],
            links: []
        )
        garments = [
            LinkedGarmentData(id: "1", name: "T-Shirt", uid: "je:asdiuasibd", animation_id: ""),
            LinkedGarmentData(id: "2", name: "Jeans", uid: "je:daiosubdob", animation_id:""),
            LinkedGarmentData(id: "3", name: "Jacket", uid: "pe:jabsbdiasbd", animation_id: "")
        ]
        
        decodedImage = getImage(base64String: user.imageBase64!)
    }
}

