//
//  AnimationMedia.swift
//  ARExperiment
//
//  Created by David Drobny on 10/12/2024.
//

import Foundation

/// Enum representing supported file types
enum SupportedFileType: String {
    case mp3 = "audio/mpeg"
    case jpg = "image/jpeg"
    case png = "image/png"
    case mov = "video/quicktime"
    
    /// Determines the file type based on file extension
    static func fileType(for fileExtension: String) -> SupportedFileType? {
        switch fileExtension.lowercased() {
        case "mp3": return .mp3
        case "jpg", "jpeg": return .jpg
        case "png": return .png
        case "mov": return .mov
        default: return nil
        }
    }
}

/// Struct to encapsulate file data and metadata
struct SelectedFile {
    let data: Data
    let filename: String
    let fileType: SupportedFileType

    /// MIME type string
    var mimeType: String {
        return fileType.rawValue
    }
}

func validateSelectedFile(at fileURL: URL) -> SelectedFile? {
    let filename = fileURL.lastPathComponent
    let fileExtension = fileURL.pathExtension
    
    // Determine file type
    guard let fileType = SupportedFileType.fileType(for: fileExtension) else {
        print("Unsupported file type: \(fileExtension)")
        return nil
    }
    
    // Attempt to read file data
    guard let fileData = try? Data(contentsOf: fileURL) else {
        print("Unable to read file data.")
        return nil
    }
    
    // Return encapsulated file
    return SelectedFile(data: fileData, filename: filename, fileType: fileType)
}

