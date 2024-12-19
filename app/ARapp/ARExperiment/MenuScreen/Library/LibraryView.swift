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


class LibraryPageData: ObservableObject {
    @Published var purchasedAnimations: [AnimationModel] = []
    @Published var garments: [GarmentModel] = []

    func fetch() {
        fetchPurchasedAnimations()
        fetchGarments()
    }

    private func fetchPurchasedAnimations() {
        guard let url = URL(string: "http://192.168.1.23:8000/library/animations") else {
            print("Invalid URL for purchased animations")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching purchased animations: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for purchased animations")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let animationsArray = json?["purchasedAnimations"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.processPurchasedAnimations(animationsArray)
                    }
                }
            } catch {
                print("Error parsing JSON for purchased animations: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func processPurchasedAnimations(_ animationsArray: [[String: Any]]) {
        var fetchedAnimations: [AnimationModel] = []
        let group = DispatchGroup()

        for animationData in animationsArray {
            guard
                let animation_id = animationData["animation_id"] as? String,
                let animation_name = animationData["animation_name"] as? String,
                let author_name = animationData["author_name"] as? String,
                let author_description = animationData["author_description"] as? String,
                let base64ProfileImage = animationData["author_profile_image"] as? String,
                let author_id = animationData["author_id"] as? String,
                let description = animationData["description"] as? String,
                let created_at = animationData["created_at"] as? String,
                let physical_width = animationData["physical_width"] as? Int,
                let physical_height = animationData["physical_height"] as? Int
            else {
                print("Did not parse purchased animation data correctly")
                continue
            }

            group.enter()

            let authorProfileImage = getImage(base64String: base64ProfileImage)

            fetchThumbnail(animation_id: animation_id) { thumbnailImage in
                if let thumbnailImage = thumbnailImage {
                    let animationModel = AnimationModel(
                        animation_name: animation_name,
                        animation_id: animation_id,
                        author_id: author_id,
                        author_name: author_name,
                        author_description: author_description,
                        description: description,
                        created_at: created_at,
                        physical_width: physical_width,
                        physical_height: physical_height,
                        thumbnail: thumbnailImage,
                        author_profile_image: authorProfileImage
                    )
                    fetchedAnimations.append(animationModel)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.purchasedAnimations = fetchedAnimations
        }
    }

    private func fetchGarments() {
        guard let url = URL(string: "http://192.168.1.23:8000/library/garments") else {
            print("Invalid URL for garments")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching garments: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for garments")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let garmentsArray = json?["garments"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.garments = garmentsArray.compactMap { garmentData in
                            guard
                                let id = garmentData["id"] as? String,
                                let name = garmentData["name"] as? String,
                                let uid = garmentData["uid"] as? String
                            else {
                                print("Did not parse garment data correctly")
                                return nil
                            }
                            return GarmentModel(id: id, name: name, uid: uid)
                        }
                    }
                }
            } catch {
                print("Error parsing JSON for garments: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func fetchThumbnail(animation_id: String, completion: @escaping (Image?) -> Void) {
        guard let url = URL(string: "http://192.168.1.23:8000/animations/\(animation_id)/thumbnail") else {
            print("Invalid thumbnail URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching thumbnail: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data, let uiImage = UIImage(data: data) else {
                print("Invalid thumbnail data")
                completion(nil)
                return
            }

            let image = Image(uiImage: uiImage)
            completion(image)
        }.resume()
    }

    private func getImage(base64String: String) -> Image {
        guard let data = Data(base64Encoded: base64String), let uiImage = UIImage(data: data) else {
            return Image(systemName: "person.circle") // Default image in case of error
        }
        return Image(uiImage: uiImage)
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
