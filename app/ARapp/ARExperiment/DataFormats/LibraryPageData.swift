//
//  LibraryPageData.swift
//  ARExperiment
//
//  Created by David Drobny on 21/12/2024.
//

import SwiftUI

class LibraryPageData: ObservableObject {
    @Published var purchasedAnimations: [AnimationModel] = []
    @Published var garments: [GarmentModel] = []
    private var animationMap: [String: AnimationModel] = [:]
    
    private var address: String = ""
    private var token: String = ""
    private var userId: String = ""
    
    private func setup(store: AppState) {
        self.address = store.externalSource
        self.token = store.authToken
        self.userId = store.userId
    }
    
    func fetch(store: AppState) {
        setup(store: store)
        let group = DispatchGroup()
        
        group.enter()
        fetchPurchasedAnimations {
            print("Fetched animations 2: \(self.purchasedAnimations)")
            group.leave()
        }
        
        group.enter()
        fetchGarments {
            group.leave()
        }

        
        group.notify(queue: .main) {
            print("Fetched animations: \(self.purchasedAnimations)")
            print("Fetched garments: \(self.garments)")
            self.constructAnimationMap()
        }
    }
    
    private func fetchPurchasedAnimations(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(address)/library/list") else {
            print("Invalid URL for purchased animations")
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching purchased animations: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data received for purchased animations")
                completion()
                return
            }
            
            do {
                if let animationsArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.processPurchasedAnimations(animationsArray)
                    }
                } else {
                    print("Error: Data is not an array of animations.")
                }
            } catch {
                print("Error parsing JSON for purchased animations: \(error.localizedDescription)")
            }
            completion()
        }.resume()
    }
    
    private func processPurchasedAnimations(_ animationsArray: [[String: Any]]) {
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
                let created_at = animationData["created_at"] as? String,
                let physical_width = animationData["physical_width"] as? Int,
                let physical_height = animationData["physical_height"] as? Int
            else {
                print("Did not parse purchased animation data correctly")
                continue
            }
            
            group.enter()
            
            let authorProfileImage = getImage(base64String: base64ProfileImage)
            
            fetchThumbnail(animation_id: animation_id) { thumbnailImage in
                if let thumbnailImage = thumbnailImage {
                    let animationModel = AnimationModel(
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
                    fetchedAnimations.append(animationModel)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.purchasedAnimations = fetchedAnimations
        }
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
                            // Allow null values
                            
                            return GarmentModel(id: id, animation_id: animation_id, name: name, uid: uid)
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
    
    private func fetchThumbnail(animation_id: String, completion: @escaping (Image?) -> Void) {
        guard let url = URL(string: "\(address)/animations/\(animation_id)/thumbnail") else {
            print("Invalid thumbnail URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    func constructAnimationMap() {
        animationMap = Dictionary(uniqueKeysWithValues: purchasedAnimations.map { ($0.animation_id, $0) })
    }
    
    func getAnimation(for animationID: String) -> AnimationModel? {
        print(animationMap)
        print("Animation detail: \(animationMap[animationID]?.author_name ?? "No author name")")
        return animationMap[animationID]
    }
    
    
    func updateGarmentAnimation(store: AppState, garmentId: String, animationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(store.externalSource)/garments/\(garmentId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(store.authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
        let requestBody: [String: Any] = [
            "animation_id": animationId
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
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

}


struct GarmentModel: Identifiable {
    let id: String
    let animation_id: String
    var name: String
    let uid: String
}

