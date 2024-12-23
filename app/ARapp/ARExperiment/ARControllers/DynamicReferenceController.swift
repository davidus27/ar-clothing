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
    
//    var selectedImage: UIImage? {
//        didSet {
//            updateReferenceImage(to: selectedImage)
//        }
//    }
    
    var selectedAnimationPath: URL? {
        didSet {
            print("Updated the animation to \(selectedAnimationPath)")
            updateAnimation(to: selectedAnimationPath)
        }
    }

    
    // MARK: - Properties
    var sceneView: ARSCNView!
    var configuration: ARWorldTrackingConfiguration!
    var videoPlayer: AVPlayer?
    var loadingPlayer: AVPlayer?
    var videoReady = false
    
    // anchors estimation
    var lastImageAnchor: ARAnchor?
    var lastJointAnchor: ARAnchor?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func updateReferenceImage(to image: UIImage?) {
        if image == nil { return }
        
        guard let cgImage = image?.cgImage else {
            fatalError("Could not convert image to CGImage.")
        }
    
        let arImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1)
        configuration.detectionImages = [ arImage ]
        
        // update existing configuration
        sceneView.session.run(configuration)
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
        
        configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        configuration.environmentTexturing = .automatic
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 4
        
        sceneView.session.run(configuration)
    }
    
    func setAuthorName() {
        guard let authorNameNode = sceneView.scene.rootNode.childNode(withName: "authorName", recursively: true) else { return }
        
        guard let textGeometry = authorNameNode.geometry as? SCNText else { return }
        
        let authorName = "David"
        textGeometry.string = authorName
    }
    
    func updateAnimation(to path: URL?) {
        guard let path = path else { return }
        
        let fileExtension = path.pathExtension.lowercased()
        
        // Print to debug
        print("Updating animation: \(path.lastPathComponent), file extension: \(fileExtension)")
        
        // If it's a video file
        if fileExtension == "mov" || fileExtension == "mp4" || fileExtension == "mp3" {
            stopCurrentPlayer()
            
            // Set up and play the video
            videoPlayer = createPlayer(from: path)
            print("Creating new player for \(path)")
            setMaterial(forNodeNamed: "video", with: videoPlayer)
            loopPlayer(videoPlayer)
            videoPlayer?.play()
            videoReady = true
            
            // Ensure video container is visible
            if let node = sceneView.scene.rootNode.childNode(withName: "video", recursively: true) {
                if let videoContainer = node.parent?.childNode(withName: "videoContainer", recursively: true) {
                    print("Unhiding video container")
                    videoContainer.isHidden = false
                }
            }
        }
        // If it's an image file
        else if fileExtension == "jpg" || fileExtension == "jpeg" || fileExtension == "png" {
            videoReady = false
            displayImage(from: path)
        }
    }

//    private func setMaterial(forNodeNamed nodeName: String, with player: AVPlayer?) {
//        guard let node = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
//        let material = SCNMaterial()
//        material.diffuse.contents = player
//        node.geometry?.materials = [material]
//
//        // Make sure the video container is visible
//        guard let videoContainer = node.parent?.childNode(withName: "videoContainer", recursively: true) else { return }
//        videoContainer.isHidden = false // Unhide the container when a new video is set
//    }



    
    private func createPlayer(from url: URL) -> AVQueuePlayer? {
        return AVQueuePlayer(url: url)
    }


    private func displayImage(from path: URL) {
        print("Displaying new image instead of video")
        guard let node = sceneView.scene.rootNode.childNode(withName: "video", recursively: true) else { return }
        
        // Load the image as a texture
        let image = UIImage(contentsOfFile: path.path)
        let material = SCNMaterial()
        material.diffuse.contents = image
        node.geometry?.materials = [material]
        
        // Hide the video player container if we're showing an image
        guard let videoContainer = node.parent?.childNode(withName: "videoContainer", recursively: true) else { return }
        videoContainer.isHidden = true
    }
    
    private func stopCurrentPlayer() {
        videoPlayer?.pause()
        videoPlayer = nil
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
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let imageAnchor = anchor as? ARImageAnchor else { return }
//        placeContent(in: imageAnchor, with: node)
        
        if let imageAnchor = anchor as? ARImageAnchor {
            placeContent(in: imageAnchor, with: node)
        } else if let bodyAnchor = anchor as? ARBodyAnchor {
            if let spineJointTransform = bodyAnchor.skeleton.modelTransform(for: .root) {
                lastJointAnchor = ARAnchor(transform: spineJointTransform)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
               // Update position when image is visible
               lastImageAnchor = imageAnchor
               placeContent(in: imageAnchor, with: node)
               
        } else if anchor == lastJointAnchor {
               // Fallback to joint anchor if image is not visible
               if lastImageAnchor == nil {
                   // placeContent(in: nil, with: node)
                   node.simdTransform = lastJointAnchor?.transform ?? matrix_identity_float4x4
               }
           }
    }
}
