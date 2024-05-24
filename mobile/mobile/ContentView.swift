//
//  ContentView.swift
//  mobile
//
//  Created by David Drobny on 25/05/2024.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {

        // guard if the device supports occulsion
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        } 
        // define a config for the occulsion
        let arViewConfig = ARWorldTrackingConfiguration()
        arViewConfig.frameSemantics = [.personSegmentationWithDepth]
        arViewConfig.planeDetection = .horizontal
        
        let arView = ARView(frame: .zero)
        
        // add config to the arView
        arView.session.run(arViewConfig)

        // Create a dark grey square model
        let mesh = MeshResource.generateBox(size: 0.05)
        let material = SimpleMaterial(color: .gray, roughness: 0.05, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
