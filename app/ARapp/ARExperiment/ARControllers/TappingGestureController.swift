//
//  TappingGestureController.swift
//  ARExperiment
//
//  Created by David Drobny on 02/10/2024.
//

import ARKit
import RealityKit


class TappingGestureController: UIViewController {
    @IBOutlet var arView: ARView!
    let virtualAssetName = "Cosmonaut_Suit"
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: self.virtualAssetName, transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        }
        else {
            print("Object placement failed - no surface found.")
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Initialize ARView
            arView = ARView(frame: self.view.bounds)
            arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(arView)

            // Set up AR session
            setupARView()
            
            // Add tap gesture recognizer
            arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
//        setupARView()
        
//        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    
    // MARK: Setup methods
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }

        
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.maximumNumberOfTrackedImages = 1
        configuration.environmentTexturing = .automatic
        
        // Enable people occlusion into the configuration
        configuration.frameSemantics.insert(.personSegmentationWithDepth)
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.load(named: entityName)
        
//        entity.generateCollisionShapes(recursive: true)
//
//        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}


extension TappingGestureController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name {
                print("Anchor added: \(anchorName)")
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}

//struct ARViewContainer: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> TappingGestureView {
//        return TappingGestureView() // Replace with your actual UIViewController
//    }
//
//    func updateUIViewController(_ uiViewController: TappingGestureView, context: Context) {
//        // Update your UIViewController when SwiftUI state changes
//    }
//}
