//
//  LibraryView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//
import SwiftUI

// Main Library View
struct LibraryView: View {
    @EnvironmentObject private var appStateStore: AppStateStore
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
        .onAppear {
            libraryData.fetch(store: appStateStore.state)
        }
    }
}

struct GarmentListView: View {
    @ObservedObject var libraryData: LibraryPageData

    var body: some View {
        Group {
            if libraryData.garments.isEmpty {
                // Placeholder when no garments are available
                VStack {
                    Text("No garments found")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("Try to add it from your profile tab or try out Custom piece of clothing down bellow.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Image(systemName: "tshirt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                // List of garments
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
                            AnimationCard(animation: libraryData.getAnimation(for: garment.animation_id))
                        }
                        .padding(.vertical, 8)
                    }
                }
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.inline)
            }
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

//class LibraryPageData: ObservableObject {
//    @Published var purchasedAnimations: [AnimationModel] = []
//    @Published var garments: [GarmentModel] = []
//    private var animationMap: [String: AnimationModel] = [:]
//
//
//    func fetch() {
//        // Fetch mock data
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.purchasedAnimations = [
////                AnimationModel(animation_name: "Animation 1", animation_id: "1", author_id: "1", author_name: "Alice", author_description: "", description: "Beautiful animation", created_at: "2024-12-10", physical_width: 10, physical_height: 10, thumbnail: Image(systemName: "star.fill"), author_profile_image: Image(systemName: "star.fill")),
////                AnimationModel(animation_name: "Animation 2", animation_id: "2", author_id: "2", author_name: "Bob", author_description: "", description: "Beautiful animation",  created_at: "2024-12-10", physical_width: 10, physical_height: 10, thumbnail: Image(systemName: "star.fill"), author_profile_image: Image(systemName: "star.fill")),
//            ]
//
//            self.garments = [
//                GarmentModel(id: "1", animation_id: "1", name: "T-Shirt", uid: "UID1234"),
//                GarmentModel(id: "2", animation_id: "2",name: "Hoodie", uid: "UID5678"),
//                GarmentModel(id: "3", animation_id: "1",name: "T-Shirt", uid: "UID1234"),
//                GarmentModel(id: "4", animation_id: "2",name: "T-Shirt", uid: "UID1234"),
//                GarmentModel(id: "5", animation_id: "2",name: "T-Shirt", uid: "UID1234"),
//                GarmentModel(id: "6", animation_id: "1", name: "T-Shirt", uid: "UID1234"),
//
//            ]
//            self.constructAnimationMap()
//        }
//    }
//    
//    
//    func constructAnimationMap() {
//        animationMap = Dictionary(uniqueKeysWithValues: purchasedAnimations.map { ($0.animation_id, $0) })
//    }
//
//    func getAnimation(for animationID: String) -> AnimationModel? {
//        return animationMap[animationID]
//    }
//}



#Preview {
    LibraryView()
        .environmentObject(AppStateStore())
}
