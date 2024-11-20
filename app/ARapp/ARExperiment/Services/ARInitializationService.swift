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
    var lastImageAnchor: ARImageAnchor?
    var lastBodyAnchor: ARBodyAnchor?
    
    func initializeScene(view: UIView, to delegatation: ARSCNViewDelegate) -> ARInitializable {
        sceneView = ARSCNView(frame: view.frame)
        view.addSubview(sceneView)
        sceneView.delegate = delegatation
        
        guard let scene = SCNScene(named: "AR assets.scnassets/Content.scn") else { return self }
        self.sceneView.scene = scene
        
        return self
    }

    @discardableResult
    func setupARView() -> ARInitializable {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        configuration.planeDetection = [ .horizontal, .vertical ]
        configuration.isLightEstimationEnabled = true
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
    
        let arImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.07)
        configuration.detectionImages = [ arImage ]
                
        // update existing configuration
        sceneView.session.run(configuration)
        
        return self
    }
    
    @discardableResult
    func addAnchorMarker(for imageAnchor: ARImageAnchor, to node: SCNNode) -> ARInitializable {
        // 1. Get the imageAnchor's world position directly
        let anchorPosition = imageAnchor.transform.columns.3
        let anchorWorldPosition = SIMD3<Float>(anchorPosition.x, anchorPosition.y, anchorPosition.z)

        // 2. Define a raycast query from the imageAnchor's position in world space
        let rayDirection = simd_make_float3(0, -1, 0) // Adjust direction if needed, based on the clothing's expected surface
        let raycastQuery = ARRaycastQuery(origin: anchorWorldPosition,
                                          direction: rayDirection,
                                          allowing: .estimatedPlane,
                                          alignment: .any)

        // 3. Perform the raycast to find a position on the estimated plane
        guard let raycastResult = sceneView.session.raycast(raycastQuery).first else {
            print("Raycast did not hit any surface.")
            return self
        }

        // 4. Create an ARAnchor at the raycast location
        let planeAnchor = ARAnchor(transform: raycastResult.worldTransform)
        sceneView.session.add(anchor: planeAnchor)

        // 5. Create a marker node at the anchor position
        let marker = SCNNode(geometry: SCNSphere(radius: 0.005))
        marker.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        marker.simdTransform = raycastResult.worldTransform

        // 6. Add the marker to the specified node
        node.addChildNode(marker)
        
        print("Image anchor: \(imageAnchor)")
        print("Raycast result: \(raycastResult.worldTransform)")
        
        return self
    }


    
    @discardableResult
    func addBodyAnchorMarker(for bodyAnchor: ARBodyAnchor) -> ARInitializable {
//        guard let skeleton = bodyAnchor.skeleton else { return self }
        let spineIndex = ARSkeleton.JointName.root
        
        // Obtain the transform for the spine
        if let spineTransform = bodyAnchor.skeleton.modelTransform(for: spineIndex) {
            let marker = SCNNode(geometry: SCNSphere(radius: 0.5))
            marker.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            marker.simdTransform = spineTransform // Position the marker at the spine
            sceneView.scene.rootNode.addChildNode(marker)
        }
        print("appended body anchor")
        return self
    }
}
