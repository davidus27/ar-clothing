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
    @State private var shouldRefresh: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Here you can manage your garments and link animations on them.")
                    .font(.body)
                    .foregroundColor(.gray)
                // Pass `libraryData` to the child view
                GarmentListView(libraryData: libraryData, shouldRefresh: $shouldRefresh)

                VStack {
                    Text("Want to create a custom garment?")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Experiment with animations on custom clothing!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    NavigationLink(destination: CustomGarmentView(libraryData: libraryData, shouldRefresh: $shouldRefresh)) {
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
        .onChange(of: shouldRefresh) {
            // Refresh the main view or fetch updated data
            print("Refreshing data...")
            libraryData.fetch(store: appStateStore.state)
            shouldRefresh = false
        }
    }
}

struct GarmentListView: View {
    @ObservedObject var libraryData: LibraryPageData
    @Binding var shouldRefresh: Bool
    
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
                    NavigationLink(destination: GarmentAnimationLinkView(shouldRefresh: $shouldRefresh, garment: garment, libraryData: libraryData)) {
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


#Preview {
    LibraryView()
        .environmentObject(AppStateStore())
}
