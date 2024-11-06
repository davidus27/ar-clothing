//
//  Untitled.swift
//  ARExperiment
//
//  Created by David Drobny on 27/10/2024.
//
import UIKit
import ARKit
import Vision

class PerformantClothingSegmentationController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    // MARK: - Properties
    private var arView: ARSCNView!
    
    private var overlayImageView: UIImageView!
    private var ciContext = CIContext()
    
    private var clothingSegmentationRequest: VNCoreMLRequest!
    private var frameCounter = 0
    private let segmentationInterval = 10  // Perform segmentation every 60 frames
    private var lastAnchor: ARAnchor?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARView()
        configureSegmentationRequest()
        startARSession()
    }
    
    private func setupARView() {
        arView = ARSCNView(frame: view.bounds)
        arView.delegate = self  // Conforming to ARSCNViewDelegate
        arView.session.delegate = self
        view.addSubview(arView)
    }
    
    private func configureSegmentationRequest() {
        // clothing segmentation part
        let model = try! VNCoreMLModel(for: clothSegmentation(configuration: MLModelConfiguration()).model)
        self.clothingSegmentationRequest = VNCoreMLRequest(model: model)
    }
    
    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .personSegmentationWithDepth
        configuration.isAutoFocusEnabled = true
        configuration.userFaceTrackingEnabled = true  // Front camera setup
        arView.session.run(configuration)
    }
    
    private func setupOverlayImageView() {
            // Add an overlay UIImageView to display the processed image.
            overlayImageView = UIImageView(frame: view.bounds)
            overlayImageView.contentMode = .scaleAspectFill
            overlayImageView.alpha = 1.0  // Adjust transparency as desired
            view.addSubview(overlayImageView)
    }
    
    // MARK: - Conversion Utility
    private func convertToUIImage(from ciImage: CIImage) -> UIImage? {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCounter += 1
        if frameCounter % segmentationInterval == 0 {
            performSegmentation(on: frame)
        }
    }
    
    private func performSegmentation(on frame: ARFrame) {
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
        try? handler.perform([clothingSegmentationRequest])
        print("Executed segmentation request")
        
        if let result = clothingSegmentationRequest.results?.first as? VNPixelBufferObservation {
            let maskPixelBuffer = result.pixelBuffer
            
            // Set the new, blended image as current.
            if let blendedImage = blend(original: frame.capturedImage, mask: maskPixelBuffer).outputImage?.oriented(.left) {
                overlayImageView.image = convertToUIImage(from: blendedImage)
            }
            
        }
    }
    
    private func blend(original framePixelBuffer: CVPixelBuffer,
                       mask maskPixelBuffer: CVPixelBuffer) -> CIFilter {
        
        // Remove the optionality from generated color intensities or exit early.
   //        guard let colors = colors else { return }
        
        // Create CIImage objects for the video frame and the segmentation mask.
        let originalImage = CIImage(cvPixelBuffer: framePixelBuffer).oriented(.right)
        var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer).oriented(.right)
        
        // Scale the mask image to fit the bounds of the video frame.
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
        
        // invert the mask image
        maskImage = maskImage.applyingFilter("CIColorInvert")
        
        // Define RGB vectors for CIColorMatrix filter.
        let vectors = [
            "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0)
        ]

        // Create a colored background image.
        let backgroundImage = maskImage.applyingFilter("CIColorMatrix",
                                                       parameters: vectors)
        
        // Blend the original, background, and mask images.
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.inputImage = originalImage
        blendFilter.backgroundImage = backgroundImage
        blendFilter.maskImage = maskImage
        return blendFilter
    }
    // MARK: - Segmentation and Contour Analysis
    private func handleSegmentation(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNPixelBufferObservation],
              let mask = results.first?.pixelBuffer else { return }
        
        let center = calculateClothingCenter(from: mask)
        updateARAnchor(at: center)
    }
    
    private func calculateClothingCenter(from mask: CVPixelBuffer) -> CGPoint? {
        // Process the binary mask, find the largest contour and calculate center
        // Convert the mask to a usable image format, e.g., UIImage or CVPixelBuffer processing
        // Code for contour detection and center calculation would go here
        
        // Placeholder code for calculated center
        return CGPoint(x: CVPixelBufferGetWidth(mask) / 2, y: CVPixelBufferGetHeight(mask) / 2)
    }
    
    // MARK: - AR Anchor and Node Handling
    private func updateARAnchor(at center: CGPoint?) {
        guard let center = center else { return }
        
        // Remove old anchor if exists
        if let lastAnchor = lastAnchor {
            arView.session.remove(anchor: lastAnchor)
        }
        
        // Perform a raycast from screen space center
        if let raycastQuery = arView.raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any),
           let raycastResult = arView.session.raycast(raycastQuery).first {
            let newAnchor = ARAnchor(transform: raycastResult.worldTransform)
            arView.session.add(anchor: newAnchor)
            lastAnchor = newAnchor
        }
    }
    
    // MARK: - Node Rendering
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor == lastAnchor {
            let dotNode = createRedDotNode()
            return dotNode
        }
        return nil
    }
    
    private func createRedDotNode() -> SCNNode {
        let dotGeometry = SCNSphere(radius: 0.01)
        dotGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let dotNode = SCNNode(geometry: dotGeometry)
        return dotNode
    }
}
