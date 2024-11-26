//
//  JapaneseAnchorController.swift
//  ARExperiment
//
//  Created by David Drobny on 19/11/2024.
//

import UIKit
import ARKit
import Vision

class JapaneseAnchorController: UIViewController, ARSCNViewDelegate {
    
    private var sceneView: ARSCNView!
    private var textRecognitionQueue = DispatchQueue(label: "textRecognitionQueue")
    private var request: VNRecognizeTextRequest!
    private let allowedSymbols = ["道", "山", "石", "火", "水", "刀", "土", "空", "月", "日", "手", "木", "竹", "糸", "川"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup ARSCNView
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        self.view.addSubview(sceneView)
        
        // Setup Text Recognition
        configureTextRecognition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func configureTextRecognition() {
        request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("Text recognition error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    let detectedText = topCandidate.string
                    
                    // Filter allowed symbols
                    if self?.allowedSymbols.contains(where: { detectedText.contains($0) }) == true {
                        self?.handleRecognizedText(topCandidate: topCandidate, boundingBox: observation.boundingBox)
                    }
                }
            }
        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ja"]
    }
    
    private func handleRecognizedText(topCandidate: VNRecognizedText, boundingBox: CGRect) {
        // Convert bounding box from Vision coordinates to SceneView coordinates
        guard let screenFrame = sceneView.session.currentFrame else { return }
        let sceneRect = VNImageRectForNormalizedRect(rect: boundingBox)
        
        // Create a bounding box node in the AR scene
        let node = SCNNode()
        let box = SCNBox(width: sceneRect.width, height: sceneRect.height, length: 0.001, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        node.geometry = box
        
        // Calculate the position based on Vision bounding box
        let hitTestResults = sceneView.hitTest(CGPoint(x: sceneRect.midX, y: sceneRect.midY), types: [.featurePoint])
        if let result = hitTestResults.first {
            node.position = SCNVector3(result.worldTransform.columns.3.x,
                                       result.worldTransform.columns.3.y,
                                       result.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    private func VNImageRectForNormalizedRect(rect: CGRect) -> CGRect {
        // Assuming full HD resolution for AR processing
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let x = rect.origin.x * screenWidth
        let y = (1 - rect.origin.y) * screenHeight
        let width = rect.width * screenWidth
        let height = rect.height * screenHeight
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        // Extract the camera frame and run Vision requests
        let buffer = currentFrame.capturedImage
        textRecognitionQueue.async {
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
            try? handler.perform([self.request])
        }
    }
}
