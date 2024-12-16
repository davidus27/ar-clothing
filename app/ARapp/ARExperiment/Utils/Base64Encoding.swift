//
//  Base64Encoding.swift
//  ARExperiment
//
//  Created by David Drobny on 10/12/2024.
//

import SwiftUI

// calculate the Base64 value of any image
// this is just throw-away function in case we need mockup images
func getBase64ImageValue(image: UIImage) -> String {
    // Convert the image to PNG data
    guard let pngData = image.pngData() else {
       print("Failed to convert image to PNG data")
       return ""
    }

    // Encode the PNG data to a Base64 string
    let base64String = pngData.base64EncodedString()
    return base64String
}

func getImage(base64String: String) -> Image {
    if base64String.isEmpty {
        return Image(systemName: "exclamationmark.triangle")
    }
    
    // Decode the Base64 string into Data
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Wrong base64 string")
        return Image(systemName: "exclamationmark.triangle")
    }
    
    // Create a UIImage from the data
    guard let uiImage = UIImage(data: imageData) else {
        fatalError("Failed to create UIImage from data")
    }
    
    // Convert UIImage to SwiftUI Image
    let image = Image(uiImage: uiImage)
    return image
}
