//
//  ARInitializationService.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//

import ARKit
import UIKit

class ARInitializationService: ARInitializable {
    var sceneView: ARSCNView!
    var configuration: ARWorldTrackingConfiguration!

    // anchors estimation
    var lastImageAnchor: ARAnchor?
    var lastJointAnchor: ARAnchor?
    
    func initializeScene(view: UIView, to delegatation: ARSCNViewDelegate) -> ARInitializable {
        sceneView = ARSCNView(frame: view.frame)
        view.addSubview(sceneView)
        sceneView.delegate = delegatation
        
        guard let scene = SCNScene(named: "AR assets.scnassets/Content.scn") else { return self }
        self.sceneView.scene = scene
        
        return self
    }

    func setupARView() -> ARInitializable {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        configuration.environmentTexturing = .automatic
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        sceneView.session.run(configuration)
        
        return self
    }
    
    @discardableResult
    func updateReferenceImage(to image: UIImage?) -> ARInitializable {
        if image == nil { return self }
        
        guard let cgImage = image?.cgImage else {
            fatalError("Could not convert image to CGImage.")
        }
    
        let arImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1)
        configuration.detectionImages = [ arImage ]
        
        // update existing configuration
        sceneView.session.run(configuration)
        
        return self
    }
}
