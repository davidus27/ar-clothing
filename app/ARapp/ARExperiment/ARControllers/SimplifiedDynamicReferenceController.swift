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
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        animationHandler.placeContent(in: imageAnchor, with: node)
    }
}
