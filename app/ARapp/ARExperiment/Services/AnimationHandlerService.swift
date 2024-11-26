//
//  AnimationInitializationService.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//
import UIKit
import ARKit

class AnimationHandlerService: AnimationHandler {
    private var sceneView: ARSCNView
    var videoPlayer: AVPlayer?
    var loadingPlayer: AVPlayer?
    var videoReady = false
    
    deinit {
        // remove observer for playerItem
        if let playerItem = videoPlayer?.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
        // remove observer for loadingItem
        if let loadingItem = loadingPlayer?.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: loadingItem)
        }
    }
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    func updateAnimation() -> AnimationHandler {
        fatalError("updateAnimation has not been implemented yet")
    }
    
    func setupVideoPlayer() -> AnimationHandler {
        videoPlayer = createPlayer(from: "movie.2", fileExtension: "mov")
        setMaterial(forNodeNamed: "video", with: videoPlayer)
        loopPlayer(videoPlayer)
        videoPlayer?.play()
        videoReady = true
        
        return self
    }
    
    private func loopPlayer(_ player: AVPlayer?) {
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) {
            (notification) in
            player?.seek(to: .zero)
//            player?.play()
        }
    }
    
    private func createPlayer(from resourceName: String, fileExtension: String) -> AVQueuePlayer? {
        guard let videoURL = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            fatalError("Couldn't find movie \(resourceName).\(fileExtension)")
        }
        return AVQueuePlayer(url: videoURL)
    }
    
    
    func setupLoadingPlayer() -> AnimationHandler {
        loadingPlayer = createPlayer(from: "loading_circle", fileExtension: "mp4")
        setMaterial(forNodeNamed: "loading", with: loadingPlayer)
        loopPlayer(loadingPlayer)
        loadingPlayer?.play()
        
        return self
    }

    private func setMaterial(forNodeNamed nodeName: String, with player: AVPlayer?) {
        guard let node = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        let material = SCNMaterial()
        material.diffuse.contents = player
        node.geometry?.materials = [material]
    }
    
    func setAuthorName() -> AnimationHandler {
        guard let authorNameNode = sceneView.scene.rootNode.childNode(withName: "authorName", recursively: true) else { return self }
        
        guard let textGeometry = authorNameNode.geometry as? SCNText else { return self }
        
        let authorName = "David"
        textGeometry.string = authorName
        
        return self
    }
    
    @discardableResult
    func placeContent(in imageAnchor: ARImageAnchor, with node: SCNNode) -> AnimationHandler {
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: true) else { return self }
        container.removeFromParentNode()
        node.addChildNode(container)
        
        // container.scale = physical size (imageAnchor.referenceImage.physicalSize)
        
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
        
        return self
    }
}
