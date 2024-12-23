//
//  MainARView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/11/2024.
//

import SwiftUI

struct MainARView: View {
    @Binding var isGuideShown: Bool
    @EnvironmentObject var appStateStore: AppStateStore
    @EnvironmentObject var userDataStore: UserDataStore
//    @Binding var appStatus: String
    @State private var selectedImage: UIImage?
    
    private func getFirstGarment() -> String {
        print("Get first garment: \(userDataStore.garments)")
        if let garment = userDataStore.garments.first {
            return garment.animation_id
        }
        return ""
    }
    
    @State private var selectedAnimationPath: URL?
    
    var body: some View {
        ZStack {
            // Background layer: AR video stream
            GenericControllerConverter(
                bindingValue: $selectedAnimationPath,
                makeUIViewController: {
                    // Only for mockups
//                     TestController()
                    DynamicReferenceController()
                },
                updateUIViewController: { (controller, animation) in
                    print("Updating controller with animation: \(selectedAnimationPath)")
                    controller.selectedAnimationPath = selectedAnimationPath
                }
            )
            .edgesIgnoringSafeArea(.all)
            
            // Top overlay: StatusView and HelpMenuButton
            VStack {
                // Top row with StatusView and HelpMenuButton
                HStack {
                    StatusView(appState: $appStateStore.state.appStatus)
                    
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
        .onAppear {
            if let url = appStateStore.animations[getFirstGarment()] {
                selectedAnimationPath = url
                print("Selected animation path: \(selectedAnimationPath)") // Check the value here
            }
        }
        .onChange(of: appStateStore.updatedAnimations) {
            print("Check updated animations")
            if appStateStore.updatedAnimations {
                print("Animations updated")
                selectedAnimationPath = appStateStore.animations[getFirstGarment()]
                appStateStore.updatedAnimations = false
            }
        }

    }

    
    private func handleHelpOption(_ option: String) {
        // Add logic for handling menu options
        print("Handle selected option: \(option)")
    }
}
