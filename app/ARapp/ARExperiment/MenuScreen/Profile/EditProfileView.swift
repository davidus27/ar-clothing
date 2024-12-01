//
//  EditProfileView.swift
//  ARExperiment
//
//  Created by David Drobny on 22/11/2024.

import SwiftUI
struct EditProfilePage: View {
    @Binding var profileImage: Image
    @Binding var name: String
    @Binding var description: String
    
    @State private var isSaving: Bool = false  // To indicate if the save process is happening
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Profile Image Section
            VStack {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .shadow(radius: 5)

                Button("Change Photo") {
                    isImagePickerPresented = true
                }
                .font(.callout)
                .foregroundColor(.blue)
            }
            
            // Name Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.headline)
                TextField("Enter your name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            // Description Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                TextEditor(text: $description)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            // Save Button
              Button(action: {
                  // Simulate saving by waiting 0.5 seconds
                  isSaving = true
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                      // After the 0.5 seconds, reset saving state and simulate saving
                      isSaving = false
                      print("Saved: \(name), \(description)")
                  }
              }) {
                  Text(isSaving ? "Saving..." : "Save")
                      .foregroundColor(.white)
                      .frame(maxWidth: .infinity)
                      .padding()
                      .background(isSaving ? Color.gray : Color.blue) // Change color when saving
                      .cornerRadius(10)
              }
              .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Profile")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(image: $profileImage)
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: Image

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
