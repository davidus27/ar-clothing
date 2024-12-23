//
//  APIClient.swift
//  ARExperiment
//
//  Created by David Drobny on 10/12/2024.
//

import Foundation
import UIKit

final class APIClient {
    static let shared = APIClient()
    private let defaultSize = 10
    
    private init() {}

    func sendAnimation(
        animation: AnimationData,
        thumbnail: UIImage,
        image: UIImage,
        source: AppStateStore
    ) async throws {
        let url = URL(string: source.state.animationAddress)!

        // Create the boundary for multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"

        // Configure the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(source.state.authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Build the multipart/form-data body
        var body = Data()

        // Add text fields
        let params: [String: Any] = [
            "animation_name": animation.animationName,
            "animation_description": animation.animationDescription,
            "is_public": animation.isPublic,
            "physical_width": Int(animation.physicalWidth) ?? defaultSize,
            "physical_height": Int(animation.physicalHeight) ?? defaultSize,
        ]

        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add the image file
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "Invalid image data", code: 0, userInfo: nil)
        }

        let fileName = "image.jpg"
        let mimeType = "image/jpeg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "Invalid image data", code: 0, userInfo: nil)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"thumbnail\"; filename=\"thumbnail.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(thumbnailData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close the body with the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Set the request body
        request.httpBody = body

        print("Request: \(request)")
        print("Body: \(String(data: body, encoding: .utf8) ?? "No body") ")
        // Execute the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")
        // Handle the response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")
    }
}

// Data extension to simplify appending strings to Data
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
