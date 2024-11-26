//
//  SimplifiedDynamicReferenceController.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//

import UIKit
import ARKit

class SimplifiedDynamicReferenceController: UIViewController, ARSCNViewDelegate {
    let arInitializer = ARInitializationService()
    var animationHandler: AnimationHandler!
    
    
    var selectedImage: UIImage? {
        didSet {
            arInitializer.updateReferenceImage(to: selectedImage)
        }
    }
    
    // Backup anchor properties
    private var isUsingFallbackAnchor = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        arInitializer
            .initializeScene(view: view, to: self)
            .setupARView()
        
        animationHandler = AnimationHandlerService(sceneView: arInitializer.sceneView)
            .setAuthorName()
            .setupLoadingPlayer()
            .setupVideoPlayer()
    }
    
    // MARK: - ARSCNViewDelegate
    //    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        guard let imageAnchor = anchor as? ARImageAnchor else { return }
    //        animationHandler.placeContent(in: imageAnchor, with: node)
    //    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        arInitializer.lastImageAnchor = imageAnchor // Save last image anchor
        animationHandler.placeContent(in: imageAnchor, with: node)
        
        // Add a visual marker for lastImageAnchor
        arInitializer.addAnchorMarker(for: imageAnchor, to: node)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let bodyAnchor = anchor as? ARBodyAnchor {
            arInitializer.lastBodyAnchor = bodyAnchor // Save last body anchor
            
            // Add a visual marker for lastBodyAnchor at the spine position
            arInitializer.addBodyAnchorMarker(for: bodyAnchor)
        }
    }
}
