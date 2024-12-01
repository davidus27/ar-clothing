//
//  AnimationView.swift
//  ARExperiment
//
//  Created by David Drobny on 28/11/2024.
//

import SwiftUI

struct AnimationView: View {
    // we are going to use UID later on to parse it
    var uid: String
    
    var animationPreview: [Image] = [
        Image(systemName: "star.fill"),
        Image(systemName: "star.fill")
    ]
    
    var body: some View {
        VStack {
            Text("Animation Detail")
                .font(.title)
                .padding()
            
            AnimationSlides(images: animationPreview)
            
            VStack {
                // Name
                Text("The Star")
                    .font(.title)
                
                HStack {
                    // author
                    Text("by:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("David")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }.padding()

            
            // Description
            HStack {
                // make this look less important
                Text("Description:")
                    .bold()
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Text("This animation transcend reality")
            }.padding()

            
            
            Button(action: {
                
            }) {
                Text("Purchase")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)

            }
            // Add more detail about the animation here
        }
    }
}

struct AnimationSlides: View {
    let images: [Image]
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack {
            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    images[index]
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))

            HStack {
                ForEach(images.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? Color.blue : Color.gray)
                        .frame(width: 10, height: 10)
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
            .padding(.top, 10)
        }
        .frame(height: 350) // Adjust height for the entire view
    }
}


struct AnimationPreviewTests: View {
    @State var uid: String = "4"
    var body : some View {
        AnimationView(uid: uid)
    }
}

#Preview {
    AnimationPreviewTests()
}
