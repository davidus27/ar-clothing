//
//  PasswordDetectionController.swift
//  ARExperiment
//
//  Created by David Drobny on 27/10/2024.
//

import UIKit
import ARKit
import Vision

final class PasswordDetectionARViewController: StatusViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var textRecognitionRequest: VNRecognizeTextRequest?
    var recognizedUID: String?
    var anchorNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize ARSCNView and set up scene
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        view.addSubview(sceneView)

        // Configure AR Session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [ .horizontal, .vertical]
        sceneView.session.run(configuration)
        
        // Set up text recognition request with additional configurations
        setupTextRecognition()
        print("Text recognition setup completed.")
    }
    
    func setupTextRecognition() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let error = error {
                print("Error during text recognition: \(error)")
                return
            }
            guard let results = request.results as? [VNRecognizedTextObservation], !results.isEmpty else {
                // print("No text found in the results.")
                return
            }
            
            print("Text recognition results found.")
            for observation in results {
                if let topCandidate = observation.topCandidates(1).first {
                    self.processRecognizedText(topCandidate.string, boundingBox: observation.boundingBox)
                }
            }
        })
        
        textRecognitionRequest?.recognitionLevel = .accurate
        textRecognitionRequest?.usesLanguageCorrection = true
        textRecognitionRequest?.customWords = ["Password", "SOURCEBOOK AR"]
        textRecognitionRequest?.regionOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
    }

    func processRecognizedText(_ text: String, boundingBox: CGRect) {
        // print("Recognized text: \(text)")

        // Check if the text contains "Password" and a UID-like pattern
        if text.contains("Password") {
            // Extract possible UID after "Password" using regex
            if let uid = extractUID(from: text) {
                recognizedUID = uid
                print("UID recognized: \(recognizedUID ?? "none")")
                placeARAnchor(fromBoundingBox: boundingBox)
            } else {
                print("No valid UID found in recognized text.")
            }
        }
    }
    
    func extractUID(from text: String) -> String? {
        // Define UID pattern: alphanumeric sequence with possible special characters
        let pattern = "[A-Za-z0-9*]+"
        
        // Create regex to match UID pattern after "Password" label
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range) {
            let uidRange = Range(match.range, in: text)
            return uidRange.map { String(text[$0]) }
        }
        
        return nil
    }

    func placeARAnchor(fromBoundingBox boundingBox: CGRect) {
        guard let recognizedUID = recognizedUID else {
            print("No recognized UID found.")
            return
        }

        let center = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
        // let screenCenter = CGPoint(x: center.x, y: center.y)
        print("Screen center calculated: \(center)")

        guard let raycastQuery = sceneView.raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any) else {
            print("Failed to create raycast query.")
            return
        }

        let raycastResults = sceneView.session.raycast(raycastQuery)
        guard let raycastResult = raycastResults.first else {
            print("No raycast result found.")
            return
        }
        
        if recognizedUID != "1ab2c3d4i8j9k0*" {
            return
        }
        print("Recognized correct UID: \(recognizedUID)")

        let anchor = ARAnchor(name: "Cosmonaut_Suit", transform: raycastResult.worldTransform)
        sceneView.session.add(anchor: anchor)
        
        print("Anchor added with UID: \(recognizedUID)")
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let uid = recognizedUID, uid == anchor.name {
            let node = SCNNode()
            node.geometry = SCNPlane(width: 0.1, height: 0.05)
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.6)
            print("Node created for anchor with UID: \(uid)")
            return node
        }
        return nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startImageRecognitionLoop()
    }
    
    func addVideoMaterialToAnchor(anchor: ARAnchor) {
        guard let uid = anchor.name, uid == recognizedUID else { return }
        
        let node = SCNNode()

        // Load video file
        guard let videoURL = Bundle.main.url(forResource: "movie.2", withExtension: "mov") else {
            print("Video file not found.")
            return
        }
        let player = AVPlayer(url: videoURL)
        let playerNode = SKVideoNode(avPlayer: player)

        // Set up SKScene
        let skScene = SKScene(size: CGSize(width: 1920, height: 1080)) // Set the size of the video
        playerNode.position = CGPoint(x: skScene.size.width / 2, y: skScene.size.height / 2)
        playerNode.size = skScene.size
        skScene.addChild(playerNode)

        // Start playing the video
        player.play()

        // Create a SCNPlane and apply the SKScene as its material
        let plane = SCNPlane(width: 0.1, height: 0.05)
        plane.firstMaterial?.diffuse.contents = skScene
        node.geometry = plane
        node.eulerAngles.x = -.pi / 2 // Rotate the plane to face the camera

        // Add the node to the scene
        self.sceneView.node(for: anchor)?.addChildNode(node)
        print("Video node added for anchor with UID: \(uid)")
    }
    
    func startImageRecognitionLoop() {
        DispatchQueue.global(qos: .userInitiated).async {
            while true {
                guard let currentFrame = self.sceneView.session.currentFrame else {
                    // print("No current frame found.")
                    continue
                }

                // Perform text recognition on the background thread
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, orientation: .up, options: [:])

                do {
                    try handler.perform([self.textRecognitionRequest!])
                    
                    // Process recognized text results on the background thread
                    guard let recognizedUID = self.recognizedUID,
                          let boundingBox = self.textRecognitionRequest?.results?.first?.boundingBox else {
                        // print("No recognized UID or bounding box.")
                        continue
                    }
                    
                    // Extract center coordinates from bounding box
                    let center = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                    
                    // Switch to main thread for accessing sceneView bounds and placing anchor
                    DispatchQueue.main.async {
                        let screenCenter = CGPoint(
                            x: center.x * self.sceneView.bounds.width,
                            y: center.y * self.sceneView.bounds.height
                        )
                        print("Screen center calculated: \(screenCenter)")

                        // Create and perform the raycast on the main thread
                        if let raycastQuery = self.sceneView.raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: .any) {
                            let raycastResults = self.sceneView.session.raycast(raycastQuery)
                            if let raycastResult = raycastResults.first {
                                let anchor = ARAnchor(name: recognizedUID, transform: raycastResult.worldTransform)
                                
                                // append Scene on this anchor so there will be video on it
                                self.addVideoMaterialToAnchor(anchor: anchor)
                                
                                self.sceneView.session.add(anchor: anchor)
                                print("Anchor added with UID: \(recognizedUID)")
                            }
                        }
                    }
                    
                } catch {
                    print("Failed to perform text recognition request: \(error)")
                }

                usleep(100_000) // 0.1 seconds
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
