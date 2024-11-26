//
//  SlideView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/11/2024.
//

import SwiftUI

struct SlideView: View {
    let slide: Slide

    var body: some View {
        VStack {
            if let imageName = slide.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding(.bottom, 16)
            }
            
            Text(slide.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            Text(slide.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding()
    }
}

struct Slide {
    let title: String
    let description: String
    let imageName: String?
}
