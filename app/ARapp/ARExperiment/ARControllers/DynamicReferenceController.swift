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
    
    // MARK: - Properties
    var sceneView: ARSCNView!
    var videoPlayer: AVPlayer?
    var loadingPlayer: AVPlayer?
    var videoReady = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        initializeScene()
        setupLoadingPlayer()
        setupVideoPlayer()
        setAuthorName()
        setupARView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Scene Setup
    func initializeScene() {
        sceneView = ARSCNView(frame: view.frame)
        view.addSubview(sceneView)
        sceneView.delegate = self
        
        guard let scene = SCNScene(named: "AR assets.scnassets/Content.scn") else { return }
        self.sceneView.scene = scene

    }
    
    func setupARView() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        configuration.environmentTexturing = .automatic
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        sceneView.session.run(configuration)
    }
    
    func setAuthorName() {
        guard let authorNameNode = sceneView.scene.rootNode.childNode(withName: "authorName", recursively: true) else { return }
        
        guard let textGeometry = authorNameNode.geometry as? SCNText else { return }
        
        let authorName = "David"
        textGeometry.string = authorName
    }
    
    
    // MARK: - Player Setup
    func setupLoadingPlayer() {
        loadingPlayer = createPlayer(from: "loading_circle", fileExtension: "mp4")
        setMaterial(forNodeNamed: "loading", with: loadingPlayer)
        loopPlayer(loadingPlayer)
        loadingPlayer?.play()
    }
    
    func setupVideoPlayer() {
        videoPlayer = createPlayer(from: "movie.2", fileExtension: "mov")
        setMaterial(forNodeNamed: "video", with: videoPlayer)
        loopPlayer(videoPlayer)
        videoPlayer?.play()
        videoReady = true
    }
    
    private func createPlayer(from resourceName: String, fileExtension: String) -> AVQueuePlayer? {
        guard let videoURL = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            fatalError("Couldn't find movie \(resourceName).\(fileExtension)")
        }
        return AVQueuePlayer(url: videoURL)
    }
    
    private func setMaterial(forNodeNamed nodeName: String, with player: AVPlayer?) {
        guard let node = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        let material = SCNMaterial()
        material.diffuse.contents = player
        node.geometry?.materials = [material]
    }
    
    private func loopPlayer(_ player: AVPlayer?) {
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) {
            (notification) in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    // MARK: - Content Placement
    func placeContent(in imageAnchor: ARImageAnchor, with node: SCNNode) {
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: true) else { return }
        container.removeFromParentNode()
        node.addChildNode(container)
        container.scale = SCNVector3(1.0, 1.0, 1.0)
        container.isHidden = false
        
        let containerName = videoReady ? "videoContainer" : "loadingContainer"
        let videoPlaneName = videoReady ? "video" : "loading"
        
        guard let videoContainer = container.childNode(withName: containerName, recursively: true) else {
            fatalError("Couldn't find video container")
        }
        
        DispatchQueue.main.async {
            videoContainer.isHidden = false
        }
        
        guard let videoPlane = container.childNode(withName: videoPlaneName, recursively: true),
              let planeGeometry = videoPlane.geometry as? SCNPlane else {
            fatalError("Couldn't find video plane")
        }
        
        let referenceImage = imageAnchor.referenceImage
        planeGeometry.width = referenceImage.physicalSize.width
        planeGeometry.height = referenceImage.physicalSize.height
        videoPlane.eulerAngles.x = -.pi / 2
    }
    
    // MARK: - AR Session
    func startARSession() {
        sceneView.session.run(sceneView.session.configuration!)
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        placeContent(in: imageAnchor, with: node)
    }
}
