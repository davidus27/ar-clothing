//
//  JapaneseSymbolController.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//

import UIKit
import ARKit
import Vision

class JapaneseSymbolController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var textRecognitionRequest: VNRecognizeTextRequest?
    var recognizedUID: String?
    var anchorNode: SCNNode?
    var textBoundingBoxLayer = CAShapeLayer()
    
    let allowedSymbols = ["道", "山", "石", "火", "水", "刀", "土", "空", "月", "日", "手", "木", "竹", "糸", "川"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize ARSCNView and set up scene
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        view.addSubview(sceneView)

        // Configure AR Session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        
        // Set up text recognition
        setupTextRecognition()
        print("Text recognition setup completed.")
        
        // Add bounding box overlay layer
        textBoundingBoxLayer.strokeColor = UIColor.red.cgColor
        textBoundingBoxLayer.lineWidth = 4
        textBoundingBoxLayer.fillColor = UIColor.clear.cgColor
        sceneView.layer.addSublayer(textBoundingBoxLayer)
        
        print("Bounding box overlay initialized.")
    }

    func setupTextRecognition() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let error = error {
                print("Error during text recognition: \(error)")
                return
            }
            
            guard let results = request.results as? [VNRecognizedTextObservation], !results.isEmpty else {
                // print("No text found in the results.")
                DispatchQueue.main.async {
                    self.clearBoundingBox()
                }
                return
            }

            DispatchQueue.main.async {
                self.clearBoundingBox()
            }
            
            for observation in results {
                print("observation: \(observation) ")
                let topCandidates = observation.topCandidates(3)
                for candidate in topCandidates {
                    self.processRecognizedText(candidate.string, boundingBox: observation.boundingBox)
                }
//                if let topCandidate = observation.topCandidates(1).first {
//                    // print("Recognized text candidate: \(topCandidate.string)")
//                    self.processRecognizedText(topCandidate.string, boundingBox: observation.boundingBox)
//                }
            }
        })
        
        textRecognitionRequest?.recognitionLanguages = ["ja"]
        textRecognitionRequest?.recognitionLevel = .accurate
        textRecognitionRequest?.usesLanguageCorrection = false
        // textRecognitionRequest?.regionOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6) // Focused area
    }

    func filterText(_ text: String) -> String {
        // Create a Set for efficient lookup
        let allowedSet = Set(allowedSymbols)
        
        // Split the text into words
        let words = text.split(separator: " ")
        
        // Filter the words
        let filteredWords = words.filter { word in
            // Check if all characters in the word are in the allowed set
            word.allSatisfy { allowedSet.contains(String($0)) }
        }
        
        // Join the filtered words back into a single string
        return filteredWords.joined(separator: " ")
    }


    func processRecognizedText(_ text: String, boundingBox: CGRect) {
//        || !filterText(text).isEmpty
        if text.contains("SOURCEBOOK AR")  {
            print("Text \(text) is in the allowed list.")
            print("Processing recognized text: \(text), Bounding box: \(boundingBox)")
            DispatchQueue.main.async {
                self.addBoundingBox(for: boundingBox)
            }
        }
    }
    
    func addBoundingBox(for boundingBox: CGRect) {
        print("Adding bounding box: \(boundingBox)")

        // Get camera feed size
        guard let currentFrame = sceneView.session.currentFrame else {
            print("No current AR frame found.")
            return
        }
        let cameraImageSize = CVImageBufferGetDisplaySize(currentFrame.capturedImage)
        let cameraWidth = cameraImageSize.width
        let cameraHeight = cameraImageSize.height

        print("Camera frame size: \(cameraWidth) x \(cameraHeight)")

        // Scale bounding box from Vision's normalized coordinates to camera coordinates
        let x = boundingBox.origin.x * cameraWidth
        let y = boundingBox.origin.y * cameraHeight
        let width = boundingBox.width * cameraWidth
        let height = boundingBox.height * cameraHeight

        let cameraBoundingBox = CGRect(x: x, y: y, width: width, height: height)
        print("Bounding box in camera coordinates: \(cameraBoundingBox)")

        // Map camera coordinates to screen coordinates
        let screenWidth = sceneView.bounds.width
        let screenHeight = sceneView.bounds.height

        let scaleX = screenWidth / cameraWidth
        let scaleY = screenHeight / cameraHeight

        let convertedX = x * scaleX
        let convertedY = y * scaleY
        let convertedWidth = width * scaleX
        let convertedHeight = height * scaleY

        // Flip Y-axis for ARKit
        let flippedY = screenHeight - (convertedY + convertedHeight)
        let flippedBoundingBox = CGRect(x: convertedX, y: flippedY, width: convertedWidth, height: convertedHeight)
        print("Final flipped bounding box: \(flippedBoundingBox)")

        // Draw bounding box
        let boxPath = UIBezierPath(rect: flippedBoundingBox)
        textBoundingBoxLayer.path = boxPath.cgPath
        textBoundingBoxLayer.isHidden = false
    }



    func clearBoundingBox() {
        textBoundingBoxLayer.path = nil
    }

//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        if let uid = recognizedUID, uid == anchor.name {
//            let node = SCNNode()
//            node.geometry = SCNPlane(width: 0.1, height: 0.05)
//            node.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.6)
//            print("Node created for anchor with UID: \(uid)")
//            return node
//        }
//        return nil
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startImageRecognitionLoop()
    }
    
    func startImageRecognitionLoop() {
        DispatchQueue.global(qos: .userInitiated).async {
            while true {
                guard let currentFrame = self.sceneView.session.currentFrame else {
                    print("No current frame found.")
                    continue
                }

                // Perform text recognition on the background thread
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, orientation: .up, options: [:])

                do {
                    try handler.perform([self.textRecognitionRequest!])
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
