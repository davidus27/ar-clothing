//
//  ImagePickingButtons.swift
//  UIComponents
//
//  Created by David Drobny on 11/11/2024.
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
            
            HStack(spacing: 5) {
                Spacer()
                Button(action: {
                    isTakingPhoto = false
                    showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle") // SF Symbol for gallery
                            .font(.headline) // Make the icon bigger
                        Text("Pick from Gallery")
                            .font(.caption) // Adjust font size
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Make button width flexible
                    .background(Color.gray.opacity(0.2)) // Light grey background
                    .cornerRadius(20) // More rounded corners
                    .foregroundColor(.black) // Text and icon color
                    .shadow(radius: 5) // Subtle shadow for depth
                }
                
                Button(action: {
                        isTakingPhoto = true
                        showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "camera") // SF Symbol for gallery
                            .font(.headline) // Make the icon bigger
                        Text("Take a Picture")
                            .font(.caption) // Adjust font size
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Make button width flexible
                    .background(Color.gray.opacity(0.2)) // Light grey background
                    .cornerRadius(20) // More rounded corners
                    .foregroundColor(.black) // Text and icon color
                    .shadow(radius: 5) // Subtle shadow for depth
                }
                Spacer()
            }
            
        }
        .onChange(of: showImagePicker) {
            // Reset `isTakingPhoto` state whenever the image picker is dismissed
            if !showImagePicker {
                isTakingPhoto = false
            }
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(
                selectedImage: $selectedImage,
                sourceType: isTakingPhoto ? .camera : .photoLibrary,
                isPresented: $showImagePicker
            ).edgesIgnoringSafeArea(.all)
        }
    }
}

//
//  ImagePicker.swift
//  ARExperiment
//
//  Created by David Drobny on 10/11/2024.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    var isPresented: Binding<Bool>
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented.wrappedValue = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented.wrappedValue = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // no updates needed
    }
}
