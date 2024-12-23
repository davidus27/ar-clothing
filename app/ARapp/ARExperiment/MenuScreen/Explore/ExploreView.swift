//
//  MarketPlace.swift
//  ARExperiment
//
//  Created by David Drobny on 27/09/2024.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var appStateStore: AppStateStore
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
                exploreData.fetchData(store: appStateStore.state)
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

            Text("Description: \(animation.author_description)")
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
            
            Text(animation.author_name)
                .font(.subheadline)
        
            Text("Description: \(animation.description)")
                .font(.caption)
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



#Preview {
    ExploreView()
        .environmentObject(AppStateStore())
}

