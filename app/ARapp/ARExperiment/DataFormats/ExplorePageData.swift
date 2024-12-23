//
//  ExploreData.swift
//  ARExperiment
//
//  Created by David Drobny on 20/12/2024.
//
import SwiftUI
// Mocked ExplorePageData and AnimationModel for Preview
class ExplorePageData: ObservableObject {
    @Published var animations: [AnimationModel] = []
    
    private var address: String = ""
    private var token: String = ""
    
    private func setup(store: AppState) {
        self.address = store.externalSource
        self.token = store.authToken
    }
    
    func purchaseAnimation(animation_id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Define the URL
        guard let url = URL(string: "\(self.address)/library/\(animation_id)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check the response status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                let error = NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update garment animation"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchData(store: AppState) {
        setup(store: store)
        guard let url = URL(string: "\(address)/explore/animations") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching animations: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let animationsArray = json?["animations"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.processAnimations(animationsArray)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func processAnimations(_ animationsArray: [[String: Any]]) {
        var fetchedAnimations: [AnimationModel] = []
        
        let group = DispatchGroup()
        for animationData in animationsArray {
            guard
                let animation_id = animationData["animation_id"] as? String,
                let animation_name = animationData["animation_name"] as? String,
                let author_name = animationData["author_name"] as? String,
                let author_description = animationData["author_description"] as? String,
                let base64ProfileImage = animationData["author_profile_image"] as? String,
                let author_id = animationData["author_id"] as? String,
                let description = animationData["description"] as? String,
                let created_at = animationData["createdAt"] as? String,
                let physical_width = animationData["physical_width"] as? Int,
                let physical_height = animationData["physical_height"] as? Int
            else {
                print("Did not parse animation data correctly")
                continue
            }
            
            group.enter()
            
            let authorProfileImage = getImage(base64String: base64ProfileImage)
            
            fetchThumbnail(animation_id: animation_id) { thumbnailImage in
                if let thumbnailImage = thumbnailImage {
                    let extendedAuthorModel = AnimationModel(
                        animation_name: animation_name,
                        animation_id: animation_id,
                        author_id: author_id,
                        author_name: author_name,
                        author_description: author_description,
                        description: description,
                        created_at: created_at,
                        physical_width: physical_width,
                        physical_height: physical_height,
                        thumbnail: thumbnailImage,
                        author_profile_image: authorProfileImage
                    )
                    fetchedAnimations.append(extendedAuthorModel)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.animations = fetchedAnimations
        }
    }
    
    private func fetchThumbnail(animation_id: String, completion: @escaping (Image?) -> Void) {
        guard let url = URL(string:  "\(address)/animations/\(animation_id)/thumbnail") else {
            print("Invalid thumbnail URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching thumbnail: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let uiImage = UIImage(data: data) else {
                print("Invalid thumbnail data")
                completion(nil)
                return
            }
            
            let image = Image(uiImage: uiImage)
            completion(image)
        }.resume()
    }
    
    private func getImage(base64String: String) -> Image {
        guard let data = Data(base64Encoded: base64String), let uiImage = UIImage(data: data) else {
            return Image(systemName: "person.circle") // Default image in case of error
        }
        return Image(uiImage: uiImage)
    }
}

struct AnimationModel: Identifiable {
    var id: String { animation_id }
    let animation_name: String
    let animation_id: String
    let author_id: String
    let author_name: String
    let author_description: String
    let description: String
    let created_at: String
    let physical_width: Int
    let physical_height: Int
    
    // images
    let thumbnail: Image
    let author_profile_image: Image
}
