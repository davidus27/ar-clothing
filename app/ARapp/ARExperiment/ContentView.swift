//
//  ContentView.swift
//  ARExperiment
//
//  Created by David Drobny on 14/09/2024.
//

import SwiftUI
import ARKit
import RealityKit

class ImageDataModel: ObservableObject {
    @Published var selectedImage: UIImage?
}


struct ContentView: View {
    @State private var showSheet: Bool = false
    @State private var activeTab: Tab = .designs
    @State private var selectedImage: UIImage?
    
    var body: some View {
        TakingImagesSelection(selectedImage: $selectedImage)
        // SwiftUIView(selectedImage: $selectedImage)
        
        GenericUIViewControllerRepresentable(
            bindingValue: $selectedImage,
            makeUIViewController: {
                TestingController()
            },
            updateUIViewController: { (controller, image) in
                controller.selectedImage = image
            }
        )
        
        ZStack(alignment: .bottom) {
            // AR Session
//            TakingImagesScreen()
            // ARViewContainerConverterTemporary<DynamicReferenceController>().edgesIgnoringSafeArea(.all)
            
            // ARViewContainerConverterTemporary<TestingController>()
            
            // Main menu
            TabBarView(activeTab: $activeTab)
        }
//        .task {
//            showSheet = true
//        }
//        .sheet(isPresented: $showSheet) {
//            SheetContentView(activeTab: $activeTab)
//        }
        }
}
