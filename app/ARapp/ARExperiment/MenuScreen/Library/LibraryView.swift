//
//  LibraryView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//
import SwiftUI

// Main Library View
struct LibraryView: View {
    @StateObject private var libraryData = LibraryPageData() // Assuming LibraryPageData conforms to ObservableObject

    var body: some View {
        NavigationView {
            VStack {
                // Main Content
                List(libraryData.garments) { garment in
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
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    libraryData.fetch() // Fetch data on appear
                }
            }
        }
    }
}

// Garment Card View
struct GarmentCard: View {
    let garment: GarmentModel

    var body: some View {
        ZStack {
            // Add T-Shirt Background
            Image(systemName: "tshirt")
                .resizable()
                .scaledToFit()
                .opacity(0.1) // Adjust opacity
                .frame(width: 90, height: 90)
            // center it
                .padding(.bottom, 15)

            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 110, height: 110)
                    .overlay(
                        Text(garment.name)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()
                    )

                Text("UID: \(garment.uid)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 110)
    }
}


// Animation Card View
struct AnimationCard: View {
    let animation: AnimationModel?

    var body: some View {
        VStack {
            if let animation = animation,
               let thumbnailData = Data(base64Encoded: animation.thumbnail_id),
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 90, height: 90)
            }

            VStack(alignment: .center) {
                Text(animation?.animation_name ?? "No Animation")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Text(animation?.author_name ?? "Unknown Author")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 110)
    }
}

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
                        if let thumbnailData = Data(base64Encoded: animation.thumbnail_id),
                           let uiImage = UIImage(data: thumbnailData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                        }

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
        guard let selectedAnimation = selectedAnimation else {
            saveConfirmationMessage = "No animation selected."
            return
        }

        // Simulate saving the animation to the garment
        // Here you could also add backend API calls or local data updates
        libraryData.purchasedAnimations.append(selectedAnimation) // Placeholder operation
        saveConfirmationMessage = "Changes saved! Returning to the Library..."
        
        // Simulate delay and navigate back
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}


// Mock Data Structures
class LibraryPageData: ObservableObject {
    @Published var purchasedAnimations: [AnimationModel] = []
    @Published var garments: [GarmentModel] = []

    func fetch() {
        // Fetch mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.purchasedAnimations = [
                AnimationModel(animation_name: "Animation 1", animation_id: "1", thumbnail_id: "", author_name: "Alice", author_profile_image: "", description: "Beautiful animation", created_at: "2024-12-10", physical_width: 10, physical_height: 10),
                AnimationModel(animation_name: "Animation 2", animation_id: "2", thumbnail_id: "", author_name: "Bob", author_profile_image: "", description: "Mesmerizing design", created_at: "2024-12-11", physical_width: 10, physical_height: 10)
            ]

            self.garments = [
                GarmentModel(id: "1", name: "T-Shirt", uid: "UID1234"),
                GarmentModel(id: "2", name: "Hoodie", uid: "UID5678")
            ]
        }
    }
}

struct GarmentModel: Identifiable {
    let id: String
    let name: String
    let uid: String
}

#Preview {
    LibraryView()
}
