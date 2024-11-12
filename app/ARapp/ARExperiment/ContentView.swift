//
//  ContentView.swift
//  ARExperiment
//
//  Created by David Drobny on 14/09/2024.
//

import SwiftUI
import ARKit
import RealityKit



struct ContentView: View {
    @State private var showSheet: Bool = false
    @State private var activeTab: Tab = .designs
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack() {
            TakingImagesSelection(selectedImage: $selectedImage)

            // this way we can pass the argument to the Controller easily
            GenericControllerConverter(
                bindingValue: $selectedImage,
                makeUIViewController: {
//                    DynamicReferenceController()
                    SimplifiedDynamicReferenceController()
                },
                updateUIViewController: { (controller, image) in
                    controller.selectedImage = image
                }
            ).edgesIgnoringSafeArea(.all)
        }
        
        ZStack(alignment: .bottom) {
            // this way we can simply rander the UIKit Controller
            // ARViewContainerConverter<DynamicReferenceController>().edgesIgnoringSafeArea(.all)
            
            // ARViewContainerConverterTemporary<TestingController>()
            
            // Main menu
//            TabBarView(activeTab: $activeTab)
        }
//        .task {
//            showSheet = true
//        }
//        .sheet(isPresented: $showSheet) {
//            SheetContentView(activeTab: $activeTab)
//        }
        }
}
