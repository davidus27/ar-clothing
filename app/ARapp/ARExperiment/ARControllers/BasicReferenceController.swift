//
//  BasicReferenceController.swift
//  ARExperiment
//
//  Created by David Drobny on 02/10/2024.
//
import UIKit
import ARKit
import RealityKit
import Foundation

class BasicReferenceController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!
    
    func listAssetCatalogs() {
        // Get all resource paths in the main bundle
        let resourcePaths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil)
        
        // Filter paths to include only those ending with ".xcassets"
        let assetCatalogs = resourcePaths.filter { $0.hasSuffix(".xcassets") }
        
        // Print the asset catalogs
        print("Asset Catalogs:")
        for catalog in assetCatalogs {
            print(catalog)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the ARSCNView
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sceneView)

        // Set the delegate
        sceneView.delegate = self
        
        listAssetCatalogs()

        // Configure AR session for image detection
        guard let arMarkers = ARReferenceImage.referenceImages(inGroupNamed: "AR Assets", bundle: nil) else {
            fatalError("AR Markers asset catalog not found.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = arMarkers
        configuration.maximumNumberOfTrackedImages = 1

        // Run the AR session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()  // Pause the AR session when the view disappears
    }

    // ARSCNViewDelegate method
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        DispatchQueue.main.async {
            self.loadCosmonautAnimation(on: node, for: imageAnchor)
        }
    }

    // Load the animation
    func loadCosmonautAnimation(on node: SCNNode, for imageAnchor: ARImageAnchor) {
        do {
            let cosmonautScene = try Entity.load(named: "CosmonautSuit_en")
            
//            self.view.scene.anchors.append(cosmonautScene)
//            ARView.scene.addAnchor(cosmonautScene)
        } catch {
            fatalError("Failed to load the cosmonaut scene.")
        }
        

    }
}

