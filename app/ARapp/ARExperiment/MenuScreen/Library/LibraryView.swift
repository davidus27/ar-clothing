//
//  LibraryView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//
import SwiftUI

// Main Library View
struct LibraryView: View {
    @StateObject private var libraryData = LibraryPageData()

    var body: some View {
        NavigationView {
            VStack {
                Text("Here you can manage your garments and link animations on them.")
                    .font(.body)
                    .foregroundColor(.gray)
                // Pass `libraryData` to the child view
                GarmentListView(libraryData: libraryData)

                VStack {
                    Text("Want to create a custom garment?")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Experiment with animations on custom clothing!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    NavigationLink(destination: CustomGarmentView(libraryData: libraryData)) {
                        Text("Add Custom Piece of Garment")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct GarmentListView: View {
    @ObservedObject var libraryData: LibraryPageData

    var body: some View {
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
            libraryData.fetch()
        }
    }
}


// Garment Card View
struct GarmentCard: View {
    let garment: GarmentModel
    private var garmentText: String {
        return garment.name.isEmpty ? "Custom garment" : garment.name
    }

    var body: some View {
        ZStack {
            // Add T-Shirt Background
            Image(systemName: "tshirt")
                .resizable()
                .scaledToFit()
                .opacity(0.1) // Adjust opacity
                .frame(width: 100, height: 100)
            // center it
                .padding(.bottom, 15)

            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.09))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(garmentText)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                if !garment.uid.isEmpty {
                    Text("UID: \(garment.uid)")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Text("")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                else {
                    Text("")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 100)
    }
}


// Animation Card View
struct AnimationCard: View {
    let animation: AnimationModel?

    var body: some View {
        VStack {
            if let animation = animation {
                animation.thumbnail
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
            }

            VStack(alignment: .center) {
                Text(animation?.animation_name ?? "No Animation")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(animation?.author_name ?? "Unknown Author")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 100)
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
                AnimationModel(animation_name: "Animation 1", animation_id: "1", author_id: "1", author_name: "Alice", description: "Beautiful animation", created_at: "2024-12-10", physical_width: 10, physical_height: 10, thumbnail: Image(systemName: "star.fill"), author_profile_image: Image(systemName: "star.fill")),
                AnimationModel(animation_name: "Animation 2", animation_id: "2", author_id: "2", author_name: "Bob", description: "Beautiful animation", created_at: "2024-12-10", physical_width: 10, physical_height: 10, thumbnail: Image(systemName: "star.fill"), author_profile_image: Image(systemName: "star.fill")),
            ]

            self.garments = [
                GarmentModel(id: "1", name: "T-Shirt", uid: "UID1234"),
                GarmentModel(id: "2", name: "Hoodie", uid: "UID5678"),
                GarmentModel(id: "3", name: "T-Shirt", uid: "UID1234"),
                GarmentModel(id: "4", name: "T-Shirt", uid: "UID1234"),
                GarmentModel(id: "5", name: "T-Shirt", uid: "UID1234"),
                GarmentModel(id: "6", name: "T-Shirt", uid: "UID1234"),

            ]
        }
    }
}


struct GarmentModel: Identifiable {
    let id: String
    var name: String
    let uid: String
}

#Preview {
    LibraryView()
}
