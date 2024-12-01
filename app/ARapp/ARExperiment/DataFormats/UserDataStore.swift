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
    var imageBase64: String // URL or path to the image
    var name: String
    var description: String
    var joinedDate: String
}

class UserDataStore: ObservableObject {
    @Published var user: UserData?
    @Published var linkedGarments: [LinkedGarmentData] = []
    
    public var didFail: Bool = false
    public var decodedImage: Image = Image(systemName: "exclamationmark.icloud.fill")
    
    // Example function for fetching user data from a REST API
    func fetchUserData() {
        // Assume we have an API URL
        guard let url = URL(string: "https://example.com/api/userdata") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            // if error occurs store it in error
            if error != nil {
                self?.didFail = true
            }
            
            guard let data = data, error == nil else { return }
            
            // Decode JSON into UserData
            let decoder = JSONDecoder()
            if let userData = try? decoder.decode(UserData.self, from: data) {
                DispatchQueue.main.async {
                    self?.user = userData
                }
            }
        }.resume()
    }
    
    func fetchMockupData() {
        user = UserData(
            id: "mockUser123", // Unique ID for the mock data
            imageBase64: "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", // base-64
            name: "John Doe",
            description: "Creative designer with a passion for art and AR.",
            joinedDate: "01/01/24"
        )
        
        decodedImage = getImage(base64String: user!.imageBase64)
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


//Example:
//struct ContentView: View {
//    @StateObject var userDataStore = UserDataStore()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                if let user = userDataStore.user {
//                    Text("Welcome, \(user.name)")
//                } else {
//                    Text("No user data available")
//                }
//
//                NavigationLink("Go to Profile", destination: ProfileView())
//            }
//            .onAppear {
//                userDataStore.fetchUserData()
//            }
//        }
//    }
//}
