//
//  HumanController.swift
//  ARExperiment
//
//  Created by David Drobny on 31/10/2024.
//

import ARKit
import RealityKit

class HumanController: UIViewController, ARSessionDelegate {
    var arView: ARView!
    
    var videoPlayer: AVPlayer?
    var videoPlayerNode: SKVideoNode?
    var videoName: String = "movie.4.second"
    var humanAnchor = AnchorEntity()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        arView.session.delegate = self
        
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("Body tracking is not supported on this device.")
        }
        arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins]
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        arView.scene.addAnchor(humanAnchor)
    }
    
    func loadVideoOverlay()  {
        guard let url = Bundle.main.url(forResource: self.videoName, withExtension: "mov") else {
            fatalError("Video source not found.")
        }
        videoPlayer = AVPlayer(url: url)
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer!)
        videoPlayer?.play()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            print("looking for anchors")
            if let bodyAnchor = anchor as? ARBodyAnchor {
                print("Found body anchor")
                // Access the torso joint transform
                let torsoTransform = bodyAnchor.skeleton.modelTransform(for: .root)
                if torsoTransform != nil { print("Found torso") }
                // placeVideoOverlay(at: torsoTransform)
            }
        }
    }
    
}
