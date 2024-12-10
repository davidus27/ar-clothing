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
