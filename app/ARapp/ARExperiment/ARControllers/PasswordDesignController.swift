//
//  PasswordDesignController.swift
//  ARExperiment
//
//  Created by David Drobny on 15/11/2024.
//

import ARKit
import Vision

class PasswordDesignController: UIViewController, ARSCNViewDelegate {
    lazy var arInitializer = ARInitializationService()
    var animationHandler: AnimationHandler!
    var statusViewController: CoolStatusViewController!
  
    var textRecognitionRequest: VNRecognizeTextRequest?
    var recognizedUID: String?

//    var selectedImage: UIImage? {
//        didSet {
//            arInitializer.updateReferenceImage(to: selectedImage)
//        }
//    }
    
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
        
        statusViewController = CoolStatusViewController()
        addChild(statusViewController)
        statusViewController.view.frame = view.bounds
        view.addSubview(statusViewController.view)
        statusViewController.didMove(toParent: self)
        
        // Restart experience handler
        statusViewController.restartExperienceHandler = { [weak self] in
            self?.restartARSession()
        }
    }
        
    func restartARSession() {
        // Restart the AR session logic
        arInitializer.setupARView()
        statusViewController.showMessage("Restarting AR Session")
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        animationHandler.placeContent(in: imageAnchor, with: node)
    }

}
