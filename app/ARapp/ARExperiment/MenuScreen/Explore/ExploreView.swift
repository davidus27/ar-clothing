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
    @State private var selectedMode: String = "Custom Clothing"


    var body: some View {
        VStack(spacing: 0) { // Zero spacing to tightly control layout
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Explore")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Image(systemName: "star")
                        .font(.title2) // Match the text size
                        .foregroundColor(.yellow)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                // Custom bounce effect
                            }
                        }
                }
                .padding(10)
            }

            
            
            // Dynamic Content
            ScrollView {
                VStack(spacing: 10) {
                    TabSelectionView(tabNames: $tabNames, selectedTab: selectedTab)
                    Picker("Animation Mode", selection: $selectedMode) {
                        Text("Custom Clothing").tag("Custom Clothing")
                        Text("Japanese Edition").tag("Japanese Edition")
                        Text("Password Edition").tag("Password Edition")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)

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
