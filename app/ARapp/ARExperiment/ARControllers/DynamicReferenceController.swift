//
//  DynamicReferenceController.swift
//  ARExperiment
//
//  Created by David Drobny on 20/10/2024.
//

import ARKit
import SceneKit
import RealityKit
import UIKit

class DynamicReferenceController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var videoPlayer: AVPlayer!
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
    }
    
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init ARView
        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        sceneView.scene = SCNScene(named: "AR assets.scnassets/Content.scn")!
        self.setARScene()
        
        
        setupARView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setVideoMaterial() {
        if let planeNode = sceneView.scene.rootNode.childNode(withName: "videoPlane", recursively: true) {
            guard let videoURL = Bundle.main.url(forResource: "movie.2", withExtension: "mov") else {
                print("Couldn't find movie")
                return
            }
            
            videoPlayer = AVQueuePlayer(url: videoURL)
            
            let videoMaterial = SCNMaterial()
            videoMaterial.diffuse.contents = videoPlayer
            
            planeNode.geometry?.materials = [videoMaterial]
            
            videoPlayer.play()
            
            videoPlayer.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: nil) {
                (notification) in
                self.videoPlayer.seek(to: .zero)
                self.videoPlayer.play()
                    print("Looping Video")
            }
        }
    }
    
    func setAuthorName() {
        if let authorNameNode = sceneView.scene.rootNode.childNode(withName: "authorName", recursively: true) {
            if let textGeometry = authorNameNode.geometry as? SCNText {
                textGeometry.string = "David"
            }
        }
    }
    
    func setARScene() {
        self.setVideoMaterial()
        self.setAuthorName()
    }
    
    func setupARView() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        
        let configuration = ARWorldTrackingConfiguration()
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        // enable people occlusion
        configuration.frameSemantics.insert(.personSegmentationWithDepth)

        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        print("Found image!!!")
        
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: true) else { return }
        container.removeFromParentNode()
        node.addChildNode(container)
        container.isHidden = false
        
        guard let videoPlane = container.childNode(withName: "videoPlane", recursively: true) else { return }
        
        // set the physical size of the video plane
        let referenceImage = imageAnchor.referenceImage
        if let planeGeometry = videoPlane.geometry as? SCNPlane {
            planeGeometry.width = referenceImage.physicalSize.width
            planeGeometry.height = referenceImage.physicalSize.height
        }
        
        videoPlane.eulerAngles.x = -.pi / 2
    }

}
