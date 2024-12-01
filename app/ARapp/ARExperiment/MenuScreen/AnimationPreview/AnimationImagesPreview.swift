//
//  AnimationImagesPreview.swift
//  ARExperiment
//
//  Created by David Drobny on 28/11/2024.
//
import SwiftUI

struct AnimationImagesPreview: View {
    
    @State private var previewImages: [Image] = []
    @State private var uids: [String] = []
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    func pullBackendData() {
        // setups uids and previewImages
        uids = [ "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        previewImages = [
            Image(systemName: "star.fill"),
            Image(systemName: "moon.fill"),
            Image(systemName: "cloud.fill"),
            Image(systemName: "sun.max.fill"),
            Image(systemName: "bolt.fill"),
            Image(systemName: "snowflake"),
            Image(systemName: "flame.fill"),
            Image(systemName: "sun.max.fill"),
            Image(systemName: "star.fill")
        ]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(previewImages.indices, id: \.self) { index in
                    NavigationLink(destination: AnimationView(uid: uids[index])) {
                        previewImages[index]
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding()
        }
        .task {
            pullBackendData()
        }
    }
}

#Preview {
    // Recent activity section
    VStack(alignment: .leading) {
        Text("Recent Activity")
            .font(.headline)
            .padding(.bottom, 5)
        AnimationImagesPreview()
    }
    .padding()
}
