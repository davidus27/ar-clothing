//
//  AppStateStore.swift
//  ARExperiment
//
//  Created by David Drobny on 09/12/2024.
//

import SwiftUI
import Combine

struct AppState {
    var value: Int
    var externalSource: String
    var appStatus: String
    var userId: String
    var authToken: String
    var animations: [String: AnimationStorage] = [:] // Animation map
    
    // mockup user
    static let initialState: AppState = .init(
        value: 0,
        externalSource: "http://192.168.1.211:8000",
        appStatus: "Initializing...",
        userId: "6768caff4f89f84e6fb5c926",
        authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzY4Y2FmZjRmODlmODRlNmZiNWM5MjYiLCJpYXQiOjE3MzQ5MjA5NTl9.IgiGhW9r4uvS74DZHJTsCgHxwqW5yQ5vPsd5xoaXUw4"
    )
    
    
    var userAddress: String {
        return "\(externalSource)/users/\(userId)"
    }
    
    var animationAddress: String {
        return "\(externalSource)/animations/"
    }
}

enum AnimationStorage: Codable {
    case mp3(URL)
    case mov(URL)
    case png(URL)
    
    // Codable implementation
    enum CodingKeys: String, CodingKey {
        case type, url
    }
    
    enum AnimationType: String, Codable {
        case mp3, mov, png
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(AnimationType.self, forKey: .type)
        let url = try container.decode(URL.self, forKey: .url)
        
        switch type {
        case .mp3: self = .mp3(url)
        case .mov: self = .mov(url)
        case .png: self = .png(url)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .mp3(let url):
            try container.encode(AnimationType.mp3, forKey: .type)
            try container.encode(url, forKey: .url)
        case .mov(let url):
            try container.encode(AnimationType.mov, forKey: .type)
            try container.encode(url, forKey: .url)
        case .png(let url):
            try container.encode(AnimationType.png, forKey: .type)
            try container.encode(url, forKey: .url)
        }
    }
}

class AppStateStore: ObservableObject {
    @Published var state: AppState
    @Published var animations: [String: URL] = [:]
    
    public var didFail: Bool = false
    
    init() {
        self.state = AppState.initialState
        self.loadAnimations()
    }
    
    // Helper method to get the documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Load animations from the local JSON file
    func loadAnimations() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("animations.json")
        
        // Check if the file exists, and if not, create it
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let defaultContent = "{}" // Empty JSON object
                try defaultContent.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to create animations.json: \(error)")
                return
            }
        }

        // Load the animations from the file
        do {
            let data = try Data(contentsOf: fileURL)
            self.animations = try JSONDecoder().decode([String: URL].self, from: data)
            print("Animations loaded: \(self.animations.count)")
        } catch {
            print("No animations found or failed to load animations: \(error)")
        }
    }
    
    // Save the animations dictionary to the local file
    func saveAnimations() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("animations.json")
        do {
            let data = try JSONEncoder().encode(self.animations)
            try data.write(to: fileURL)
            print("Animations saved to \(fileURL.path)")
        } catch {
            print("Failed to save animations: \(error)")
        }
    }

    // Function to download an animation from the server and save it locally
    func downloadAnimation(animationId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(state.animationAddress)\(animationId)/animation")!
        
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            if let error = error {
                print("Failed to download animation: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                return
            }

            // Log the response headers for debugging
            print("Response headers: \(httpResponse.allHeaderFields)")

            guard httpResponse.statusCode == 200 else {
                print("Failed with status code: \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            // Check for correct MIME type
            guard let mimeType = httpResponse.mimeType, mimeType == "image/jpeg" else {
                print("Unsupported MIME Type: \(httpResponse.mimeType ?? "unknown")")
                completion(.failure(NSError(domain: "Unsupported MIME Type", code: 0, userInfo: nil)))
                return
            }

            // Save the downloaded file locally
            do {
                let fileManager = FileManager.default
                let documentsURL = self.getDocumentsDirectory()
                let destinationURL = documentsURL.appendingPathComponent("\(animationId).jpg")
                
                if let location = location {
                    try fileManager.moveItem(at: location, to: destinationURL)
                    self.animations[animationId] = destinationURL
                    self.saveAnimations()  // Save the animations map after adding the new one
                    completion(.success(true))
                }
            } catch {
                print("Failed to save animation: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Example function for fetching app state (could be expanded to make an API call)
    func fetchAppState() {
        // Implementation for fetching app state, if necessary
    }
}


