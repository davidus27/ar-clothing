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
        VStack(spacing: 10) {
            Text("Explore")
                .font(.title)
                .fontWeight(.semibold)
            TabSelectionView(tabNames: $tabNames, selectedTab: selectedTab)
            Spacer()
            // show content based on the selectedTab value
//            if selectedTab == 0 {
//                CustomClothingView(data: data.fetchPreviews(of: CustomClothing.self))
//            } else if selectedTab == 1 {
//                JapaneseEditionView(data: data.fetchPreviews(of: JapaneseEdition.self))
//            } else if selectedTab == 2 {
//                
//            }
            Spacer()
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .foregroundColor(isSelected ? .white : .black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
        }
        .animation(.easeInOut, value: isSelected)
    }
}


#Preview {
    ExploreView()
}
