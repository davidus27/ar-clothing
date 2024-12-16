//
//  FilePicker.swift
//  ARExperiment
//
//  Created by David Drobny on 10/12/2024.
//

import SwiftUI

struct FilePicker: View {
    @Binding var selectedFile: Data?  // For the selected file as Data
    @Binding var isPresented: Bool    // To control the presentation of the picker

    @State private var fileURL: URL? = nil  // To hold the file URL

    var body: some View {
        VStack {
            Text("Select a file")
                .font(.headline)
                .padding()

            if let fileURL = fileURL {
                Text("Selected file: \(fileURL.lastPathComponent)")
                    .font(.subheadline)
                    .padding()

                Button("Use this file") {
                    if let fileData = try? Data(contentsOf: fileURL) {
                        selectedFile = fileData  // Pass the selected file data back
                    }
                    isPresented = false  // Dismiss the file picker
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: [.image, .movie],  // Modify this to accept other file types as well
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    fileURL = url  // Get the URL of the selected file
                }
            case .failure(let error):
                print("Failed to select file: \(error.localizedDescription)")
            }
        }
    }
}
