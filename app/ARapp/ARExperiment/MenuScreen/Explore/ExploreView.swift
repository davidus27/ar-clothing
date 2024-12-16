//
//  MarketPlace.swift
//  ARExperiment
//
//  Created by David Drobny on 27/09/2024.
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var exploreData = ExplorePageData()
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Search animations or artists", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Text("Featured Artists")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            let uniqueAnimations = Array(
                                Dictionary(grouping: exploreData.animations, by: \.author_id)
                                    .compactMapValues { $0.first }
                                    .values
                                    .prefix(5)
                            )
                            
                            ForEach(uniqueAnimations, id: \.id) { animation in
                                NavigationLink(destination: ArtistProfileView(animation: animation)) {
                                    FeaturedArtistCard(animation: animation)
                                }
                                .foregroundStyle(.black)
                                .background(Color.clear)
                            }

                        }
                        .padding(.horizontal)
                    }
                    .background(Color.clear)
                    
                    Text("Recently Added")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(exploreData.animations.sorted(by: { $0.created_at > $1.created_at }).prefix(3), id: \ .id) { animation in
                                NavigationLink(destination: AnimationPreviewView(animation: animation)) {
                                    AnimationGridItem(animation: animation)
                                }
                                .foregroundStyle(.black)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Animations Grid
                    Text("Explore Animations")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 150), spacing: 16)
                    ], spacing: 16) {
                        ForEach(exploreData.animations, id: \.id) { animation in
                            NavigationLink(destination: AnimationPreviewView(animation: animation)) {
                                AnimationGridItem(animation: animation)
                            }
                            .foregroundStyle(.black)
                            .background(Color.clear)
                        }
                    }
                    .padding(.horizontal)
                }
            }.background(Color.clear)
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                exploreData.fetchData()
            }
            .background(Color.clear)
        }
    }
}

struct ArtistProfileView: View {
    let animation: AnimationModel

    var body: some View {
        VStack(spacing: 20) {
            animation.author_profile_image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
            
            Text(animation.author_name)
                .font(.title)
                .bold()

            Text("Joined: \(animation.created_at)")
                .font(.subheadline)

            Text("Description: Placeholder for backend description.")
                .font(.body)
                .padding()

            Spacer()
        }
        .padding()
        .navigationTitle(animation.author_name)
        .background(Color.clear)
    }
}

struct AnimationPreviewView: View {
    let animation: AnimationModel

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                
                animation.thumbnail
                        .resizable()
//                        .frame(width: 400, height: 500)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
            }
            .cornerRadius(8)

            Text(animation.animation_name)
                .font(.title)
                .bold()

            Text(animation.description)
                .font(.body)
                .padding()

            Button(action: {
                // Purchase action logic
            }) {
                Text("Purchase")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Animation Preview")
    }
}

struct FeaturedArtistCard: View {
    let animation: AnimationModel

    var body: some View {
        VStack {
            animation.author_profile_image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            Text(animation.author_name)
                .font(.headline)
                .padding(.top, 8)
        }
        .frame(width: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct AnimationGridItem: View {
    let animation: AnimationModel

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)

                    
                    animation.thumbnail
                        .resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
            }
            .cornerRadius(8)

            Text(animation.animation_name)
                .font(.headline)
                .lineLimit(1)

            Text(animation.author_name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}


// Mocked ExplorePageData and AnimationModel for Preview
class ExplorePageData: ObservableObject {
    @Published var animations: [AnimationModel] = []

    func fetchData() {
          guard let url = URL(string: "http://localhost:8000/explore/animations") else {
              print("Invalid URL")
              return
          }

          URLSession.shared.dataTask(with: url) { data, response, error in
              if let error = error {
                  print("Error fetching animations: \(error.localizedDescription)")
                  return
              }

              guard let data = data else {
                  print("No data received")
                  return
              }

              do {
                  let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                  
                  if let animationsArray = json?["animations"] as? [[String: Any]] {
                      DispatchQueue.main.async {
                          self.processAnimations(animationsArray)
                      }
                  }
              } catch {
                  print("Error parsing JSON: \(error.localizedDescription)")
              }
          }.resume()
      }

      private func processAnimations(_ animationsArray: [[String: Any]]) {
          var fetchedAnimations: [AnimationModel] = []

          let group = DispatchGroup()
          for animationData in animationsArray {
              guard
                  let animation_id = animationData["animation_id"] as? String,
                  let animation_name = animationData["animation_name"] as? String,
                  let author_name = animationData["author_name"] as? String,
                  let base64ProfileImage = animationData["author_profile_image"] as? String,
                  let author_id = animationData["author_id"] as? String,
                  let description = animationData["description"] as? String,
                  let created_at = animationData["created_at"] as? String,
                  let physical_width = animationData["physical_width"] as? Int,
                  let physical_height = animationData["physical_height"] as? Int
              else {
                  print("Did not parse animation data correctly")
                  continue
              }

              group.enter()

              let authorProfileImage = getImage(base64String: base64ProfileImage)

              fetchThumbnail(animation_id: animation_id) { thumbnailImage in
                  if let thumbnailImage = thumbnailImage {
                      let extendedAuthorModel = AnimationModel(
                          animation_name: animation_name,
                          animation_id: animation_id,
                          author_id: author_id,
                          author_name: author_name,
                          description: description,
                          created_at: created_at,
                          physical_width: physical_width,
                          physical_height: physical_height,
                          thumbnail: thumbnailImage,
                          author_profile_image: authorProfileImage
                      )
                      fetchedAnimations.append(extendedAuthorModel)
                  }
                  group.leave()
              }
          }
          
          print("Fetched animations: \(fetchedAnimations)")

          group.notify(queue: .main) {
              self.animations = fetchedAnimations
          }
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

struct AnimationModel: Identifiable {
    var id: String { animation_id }
    let animation_name: String
    let animation_id: String
    let author_id: String
    let author_name: String
    let description: String
    let created_at: String
    let physical_width: Int
    let physical_height: Int
    
    // images
    let thumbnail: Image
    let author_profile_image: Image
}

#Preview {
    ExploreView()
}

