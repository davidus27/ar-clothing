//
//  GarmentAnimationLinkView.swift
//  ARExperiment
//
//  Created by David Drobny on 12/12/2024.
//

import SwiftUI


// View for Linking Garment to Animation
struct GarmentAnimationLinkView: View {
    let garment: GarmentModel
    @ObservedObject var libraryData: LibraryPageData
    @State private var selectedAnimation: AnimationModel?
    @Environment(\.presentationMode) var presentationMode // To navigate back
    
    @State private var saveConfirmationMessage: String? // Optional message for user feedback

    @State private var animationWasChanged = false
    
    var body: some View {
        VStack {
            HStack {
                GarmentCard(garment: garment)

                VStack(spacing: 4) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)

                    Text("Linked to")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                AnimationCard(animation: selectedAnimation)
            }
            .padding()

            // Animation Selection List
            List(libraryData.purchasedAnimations) { animation in
                Button(action: {
                    selectedAnimation = animation
                    onAnimationChange()
                }) {
                    HStack {
                        animation.thumbnail
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading) {
                            Text(animation.animation_name)
                                .font(.headline)
                            Text(animation.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Animation")
            .navigationBarTitleDisplayMode(.inline)

            Spacer()

            if animationWasChanged {
                // Save Button
                Button(action: {
                    saveChanges()
                }) {
                    Text("Save Changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            }
            
            // Confirmation Message
            if let message = saveConfirmationMessage {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.bottom, 10)
            }
        }
    }

    func onAnimationChange() {
        animationWasChanged = true
    }
    
    private func saveChanges() {
        guard selectedAnimation != nil else {
            saveConfirmationMessage = "No animation selected."
            return
        }

//        libraryData.purchasedAnimations.append(selectedAnimation) // Placeholder operation
        saveConfirmationMessage = "Changes saved! Returning back..."
        
        // Simulate delay and navigate back
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

