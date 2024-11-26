//
//  AppGuideView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/11/2024.
//

import SwiftUI

struct AppGuideView: View {
    @Binding var isGuideShown: Bool // Binding to control when to hide/show the guide
    @State private var currentSlideIndex: Int = 0 // Tracks the current slide

    // Slide content
    private let slides: [Slide] = [
        Slide(title: "Welcome!", description: "Discover our app and its amazing features.", imageName: "intro_image"),
        Slide(title: "AR on Custom Clothing", description: "Take a picture of your own clothing, add animations, and save it!", imageName: "custom_clothing"),
        Slide(title: "AR on Our Clothing", description: "Purchase our custom clothing and start using AR immediately.", imageName: "our_clothing"),
        Slide(title: "Explore Marketplace", description: "Discover animations in our marketplace.", imageName: "marketplace"),
        Slide(title: "How to Use", description: "Simply move your camera to the right place to get started.", imageName: "how_to_use"),
        Slide(title: "Status Indicators", description: "Check the app's state in the top-left corner.", imageName: "status_indicators"),
        Slide(title: "Create Your Designs!", description: "Unleash your creativity with your custom designs.", imageName: "create_designs"),
        Slide(title: "Have Fun!", description: "Experiment and enjoy your AR experience.", imageName: "have_fun")
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentSlideIndex) {
                ForEach(0..<slides.count, id: \.self) { index in
                    SlideView(slide: slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Disable default dots
            .edgesIgnoringSafeArea(.all)

            // Progress Indicators
            HStack {
                ForEach(0..<slides.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentSlideIndex ? Color.blue : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 16)

            // Navigation Buttons
            HStack {
                Button(action: goBack) {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .disabled(currentSlideIndex == 0)

                Button(action: skipGuide) {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }

                Button(action: goNext) {
                    Text(currentSlideIndex == slides.count - 1 ? "Continue" : "Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    // Navigation Handlers
    private func goBack() {
        if currentSlideIndex > 0 {
            currentSlideIndex -= 1
        }
    }

    private func goNext() {
        if currentSlideIndex < slides.count - 1 {
            currentSlideIndex += 1
        } else {
            isGuideShown = false // Dismiss guide
        }
    }

    func skipGuide() {
        isGuideShown = false // Dismiss guide
    }
}

struct PreviewAppGuilde : View {
    @State private var isGuideShown: Bool = false
    var body: some View {
        AppGuideView(isGuideShown: $isGuideShown)
    }
}

#Preview {
    PreviewAppGuilde()
}
