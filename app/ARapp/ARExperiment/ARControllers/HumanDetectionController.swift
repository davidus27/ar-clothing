//
//  HumanDetectionController.swift
//  ARExperiment
//
//  Created by David Drobny on 30/10/2024.
//

import UIKit
import ARKit
import RealityKit

class HumanDetectionController: UIViewController, ARSessionDelegate {

    // MARK: - Properties
    var arView: ARView!
    var videoPlayer: AVPlayer?
    var videoPlayerNode: SKVideoNode?
    var videoName: String = "movie.4.second"
    var characterAnchor = AnchorEntity()

    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        // Set up AR view
        arView = ARView(frame: view.frame)
        view.addSubview(arView)
        
        // Assign the session delegate
        arView.session.delegate = self
        arView.automaticallyConfigureSession = true
        arView.debugOptions = [.showStatistics, .showFeaturePoints, .showSceneUnderstanding]
        
        // Load video
        // loadVideoOverlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        // Start AR session
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        arView.scene.addAnchor(characterAnchor)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause AR session
        arView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                print("Found body anchor")
                characterAnchor.position = simd_make_float3(bodyAnchor.transform.columns.3)
                characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
                // Access the torso joint transform
                let torsoTransform = bodyAnchor.skeleton.modelTransform(for: .root)
                if torsoTransform != nil { print("Found torso") }
                placeVideoOverlay(at: torsoTransform)
            }
        }
    }
    
    func placeVideoOverlay(at transform: simd_float4x4?) {
        print("Trying to find torso")
        guard let torsoTransform = transform else { return }
        
        // Remove any existing video nodes
        arView.scene.findEntity(named: self.videoName)?.removeFromParent()
//        arView.scene.rootNode.childNode(withName: self.videoName, recursively: true)?.removeFromParentNode()
        
        // Create a new scene node for the video overlay
        let videoPlane = SCNPlane(width: 0.3, height: 0.4) // Adjust size as necessary
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        
        // self.loadVideoOverlay()
        print("Loaded video overlay")
        
        if let videoPlayerNode = videoPlayerNode {
            videoPlayerNode.size = skScene.size
            videoPlayerNode.position = CGPoint(x: skScene.size.width / 2, y: skScene.size.height / 2)
            skScene.addChild(videoPlayerNode)
        }
        
        videoPlane.firstMaterial?.diffuse.contents = skScene
        let videoNode = SCNNode(geometry: videoPlane)
        videoNode.name = self.videoName
        videoNode.simdTransform = torsoTransform
        
        // Offset to align with the torso position
         videoNode.position.z = torsoTransform.columns.3.z - 0.1
        
        // arView.scene.rootNode.addChildNode(videoNode)
    }

    func loadVideoOverlay()  {
        guard let url = Bundle.main.url(forResource: self.videoName, withExtension: "mov") else {
            fatalError("Video source not found.")
        }
        videoPlayer = AVPlayer(url: url)
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer!)
        videoPlayer?.play()
    }
}
