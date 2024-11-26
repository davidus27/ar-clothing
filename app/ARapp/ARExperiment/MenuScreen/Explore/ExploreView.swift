//
//  MarketPlace.swift
//  ARExperiment
//
//  Created by David Drobny on 27/09/2024.
//

import SwiftUI

struct ExploreView: View {
    var data: ExplorePageData = MockExplorePageData()
    @State var tabNames: [String] = ["Custom clothing", "Japanese edition", "Password edition"]
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) { // Zero spacing to tightly control layout
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Explore")
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    Image(systemName: "star")
                        .font(.title) // Match the text size
                        .foregroundColor(.yellow)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                // Custom bounce effect
                            }
                        }
                }
            }

            
            
            // Dynamic Content
            ScrollView {
                VStack(spacing: 10) {
                    TabSelectionView(tabNames: $tabNames, selectedTab: selectedTab)

                    // Dynamic components below the header
                    AnimationListItem(onButtonCreatePressed: {
                        print("Pressed Create button in AnimationListItem")
                    })
                    
                    Text("Featured artists")
                        .font(.headline)
                        .fontWeight(.heavy)
                    
                    ExploreArtist(
                        author: Author(
                            id: 1,
                            profileImageName: "author1",
                            name: "John Doe",
                            contentImageName: "photo",
                            description: "John is a musician known for his soulful tracks and meaningful lyrics."
                        ),
                        onProfileTap: {
                            print("Navigate to John's profile")
                        }
                    )
                    
                    Text("New becoming artists")
                        .font(.headline)
                        .fontWeight(.heavy)
                    
                    ExploreArtist(
                        author: Author(
                            id: 2,
                            profileImageName: "author2",
                            name: "Jane Smith",
                            contentImageName: "photo",
                            description: "Jane is a visual artist creating surreal digital art with stunning detail."
                        ),
                        onProfileTap: {
                            print("Navigate to Jane's profile")
                        }
                    )
                }
            }
        }
    }
}


#Preview {
    ExploreView()
}
