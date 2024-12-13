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
                            ForEach(exploreData.animations.prefix(5), id: \ .id) { animation in
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
                            ForEach(exploreData.animations.sorted(by: { $0.created_at > $1.created_at }).prefix(5), id: \ .id) { animation in
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
                exploreData.fetch()
            }
            .background(Color.clear)
        }
    }
}

struct ArtistProfileView: View {
    let animation: AnimationModel

    var body: some View {
        VStack(spacing: 20) {
            if let profileImageData = Data(base64Encoded: animation.author_profile_image),
               let uiImage = UIImage(data: profileImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(animation.author_name.prefix(1))
                            .font(.largeTitle)
                            .bold()
                    )
            }

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

                if let thumbnailData = Data(base64Encoded: animation.thumbnail_id),
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                }
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
            if let profileImageData = Data(base64Encoded: animation.author_profile_image),
               let uiImage = UIImage(data: profileImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(animation.author_name.prefix(1))
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    )
            }

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

                if let thumbnailData = Data(base64Encoded: animation.thumbnail_id),
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                }
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

    func fetch() {
        // Simulate fetch here. In real code, this would perform a network request.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animations = [
                AnimationModel(animation_name: "Animation 1", animation_id: "1", thumbnail_id: "", author_name: "Alice", author_profile_image: "", description: "Beautiful animation", created_at: "2024-12-10", physical_width: 10, physical_height: 10),
                AnimationModel(animation_name:"Animation 2", animation_id: "2", thumbnail_id: "", author_name: "Bob", author_profile_image: "", description: "Mesmerizing design", created_at: "2024-12-11", physical_width: 10, physical_height: 10),
                AnimationModel(animation_name:"Animation 2", animation_id: "3", thumbnail_id: "", author_name: "Bob", author_profile_image: "", description: "Mesmerizing design", created_at: "2024-12-11", physical_width: 10, physical_height: 10),
                AnimationModel(animation_name:"Animation 2", animation_id: "4", thumbnail_id: "", author_name: "Bob", author_profile_image: "", description: "Mesmerizing design", created_at: "2024-12-11", physical_width: 10, physical_height: 10),
                AnimationModel(animation_name:"Animation 2", animation_id: "5", thumbnail_id: "", author_name: "Bob", author_profile_image: "", description: "Mesmerizing design", created_at: "2024-12-11", physical_width: 10, physical_height: 10),
            ]
        }
    }
}

struct AnimationModel: Identifiable {
    var id: String { animation_id }
    let animation_name: String
    let animation_id: String
    let thumbnail_id: String
    let author_name: String
    let author_profile_image: String
    let description: String
    let created_at: String
    let physical_width: Int
    let physical_height: Int
}

#Preview {
    ExploreView()
}

