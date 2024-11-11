//
//  TakingImagesScreen.swift
//  ARExperiment
//
//  Created by David Drobny on 10/11/2024.
//
import SwiftUI

struct TakingImagesSelection: View {
    @Binding var selectedImage: UIImage? // Holds the selected image
    @State private var showImagePicker: Bool = false
    @State private var isTakingPhoto: Bool = false
    
    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            HStack {
                Button("Pick from Gallery") {
                    isTakingPhoto = false
                    showImagePicker = true
                }
                .padding()
                
                Button("Take a Picture") {
                    isTakingPhoto = true
                    showImagePicker = true
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(
                selectedImage: $selectedImage,
                sourceType: isTakingPhoto ? .camera : .photoLibrary,
                isPresented: $showImagePicker
            )
        }
    }
}
