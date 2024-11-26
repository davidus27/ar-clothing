//
//  MainARView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/11/2024.
//

import SwiftUI

struct MainARView: View {
    @Binding var isGuideShown: Bool
    @Binding var appStatus: String
    @State private var selectedImage: UIImage?
    
    
    var body: some View {
        ZStack {
            // Background layer: AR video stream
            GenericControllerConverter(
                bindingValue: $selectedImage,
                makeUIViewController: {
                    // Only for mockups
                     TestController()
//                    DynamicReferenceController()
                },
                updateUIViewController: { (controller, image) in
                    // controller.selectedImage = image
                }
            )
            .edgesIgnoringSafeArea(.all)
            
            // Top overlay: StatusView and HelpMenuButton
            VStack {
                // Top row with StatusView and HelpMenuButton
                HStack {
                    StatusView(appState: $appStatus)
                    
                    HelpMenuButton(
                        onReset: {
                            print("Trashed")
                        },
                        onHelp: {
                            isGuideShown = true
                            print("Helped")
                        }
                    )
                }
            }
        }
    }

    
    private func handleHelpOption(_ option: String) {
        // Add logic for handling menu options
        print("Handle selected option: \(option)")
    }
}
