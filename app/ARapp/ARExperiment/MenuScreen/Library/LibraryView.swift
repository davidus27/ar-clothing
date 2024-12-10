//
//  LibraryView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI

struct LibraryView: View {
    @Binding var activeTab: TabOption
    @State var effectTabs: [String] = ["Global effects", "Image anchor", "Interactive"]
    @State private var selectedEffect = 0

    @State var ownershipTabs: [String] = ["Purchased", "Authored"]
    @State private var selectedOwnership = 0
    
    var body: some View {
        VStack(spacing: 0) { // Zero spacing to tightly control layout
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Library")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Image(systemName: "plus.square.on.square")
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
                VStack(spacing: 20) {
                    TabSelectionView(tabNames: $effectTabs, selectedTab: selectedEffect)
                        .padding(.horizontal)
                    TabSelectionView(tabNames: $ownershipTabs, selectedTab: selectedOwnership)
                        .padding(.horizontal)
                    
                    AnimationListItem(onButtonCreatePressed: {
                        activeTab = .create
                        print("Button create pressed")
                    })
                    Spacer()
                }
            }
        }
    }
}

#Preview {
//    LibraryView()
}
