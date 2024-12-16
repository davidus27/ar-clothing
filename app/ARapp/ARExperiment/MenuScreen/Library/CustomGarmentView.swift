//
//  CustomGarmentView.swift
//  ARExperiment
//
//  Created by David Drobny on 12/12/2024.
//
import SwiftUI

struct CustomGarmentView: View {
    @ObservedObject var libraryData: LibraryPageData
    @State private var customImage: UIImage? // For user-uploaded or captured image
    @State private var selectedAnimation: AnimationModel? // Selected animation
    @Environment(\.presentationMode) var presentationMode
    @State var validationMessage: String = ""
    @State private var garment: GarmentModel = GarmentModel(
        id: "",
        name: "",
        uid: ""
    )
    var body: some View {
        VStack {
            // Existing Image Selection Section
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create Your Custom Garment")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Follow these steps to create a custom garment that will interact with augmented reality (AR):")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Step 1: Choose name for your garment")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Text("Garment name")
                        .font(.subheadline)
                    TextField("Enter garment name", text: $garment.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    
                    
                    Divider()
                    
                    Text("Step 2: Upload an image of your garment. Please ensure the image is clear with good lighting. The garment needs to have unique features to be recognized by AR")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    VStack {
                        if customImage != nil {
                            Text("Selected image:")
                                .foregroundColor(.secondary)
                        } else {
                            Text("No image selected")
                                .foregroundColor(.secondary)
                        }
                        
                        // Buttons for picking or capturing an image
                        TakingImagesSelection(selectedImage: $customImage, onImageSelected: {
                            print("New image selected")
                            guard let customImage else { return }
                            checkImageQuality(image: customImage)
                        })
                        
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Divider()
                    
                    Text("Step 3: Select available animations to apply")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    // Animation Selection Section
                    VStack {
                        Text("Link an Animation")
                            .font(.headline)
                            .padding(.bottom)
                        
                        if let selectedAnimation {
                            // Display selected animation details
                            AnimationCard(animation: selectedAnimation)
                                .padding()
                        } else {
                            Text("No animation selected")
                                .foregroundColor(.secondary)
                        }
                        
                        NavigationLink(destination: GarmentAnimationLinkView(garment: garment, libraryData: libraryData)) {
                            HStack {
                                // Garment Image and Details
                                GarmentCard(garment: garment)
                                
                                // Arrow and Link Text
                                VStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                    
                                    Text("Linked to")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                
                                // Placeholder for Animation (empty or populated)
                                AnimationCard(animation: libraryData.purchasedAnimations.first)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    Divider()
                    
                    Text("Step 4: Review your selection and save changes")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                }
                .padding()
            }
            

            Spacer()

            if customImage != nil && !garment.name.isEmpty && selectedAnimation != nil {
                // Save Button
                Button(action: {
                    saveCustomGarment()
                }) {
                    Text("Save Custom Garment")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }

            }
        }
        .navigationTitle("Create Custom Garment")
    }
    
    private func checkImageQuality(image: UIImage) {
        // Check if selected media is valid and upload accordingly
        print("validation updated")
        
        validationMessage = ""
        if !isResolutionSufficient(image: image) {
            validationMessage = "Image resolution is too low. For better quality use at least 480x480 resolution."
        }
        
        if !isHistogramDistributionGood(image: image) {
            validationMessage += "\nRecognition works better on images with more unique colors and patterns."
        }
        
        validationMessage = "\n\nImage uploaded successfully."
    }

    private func saveCustomGarment() {
        // Add the custom garment to the library
        let customGarment = GarmentModel(
            id: UUID().uuidString, // Generate a unique ID
            name: "Custom Garment",
            uid: "Custom-\(UUID().uuidString.prefix(4))" // Example UID
        )
        libraryData.garments.append(customGarment)

        print("go back")
        presentationMode.wrappedValue.dismiss() // Navigate back
    }
}
