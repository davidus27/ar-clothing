//
//  Untitled.swift
//  ARExperiment
//
//  Created by David Drobny on 27/10/2024.
//

import UIKit
import Vision
import ARKit
import RealityKit
import MetalKit
import AVFoundation
import CoreImage.CIFilterBuiltins
import CoreML
import SceneKit           // For 3D content and SCNNode
import SpriteKit          // For animations with SKScene and SKVideoNode
import Vision             // For image analysis and segmentation


final class PerformantClothingSegmentationController: UIViewController {
    
    // The Vision requests and the handler to perform them.
    private var clothesSegmentationRequest: VNCoreMLRequest!
    private var arSession: ARSession! // Add ARSession property
    private var arView: ARView!
    private var sceneView: ARSCNView!
    private var anchor: ARAnchor?
    
    private var frameCount = 0
    private let frameSkipCount = 60 // this is how many fps we skip not performing clothing segmentation
    
    
    // A structure that contains RGB color intensity values.
    private var colors: AngleColors?
    var cameraView: MTKView! {
        didSet {
            guard metalDevice == nil else { return }
            setupMetal()
            setupCoreImage()
            setupCaptureSession()
        }
    }
    
    // The Metal pipeline.
    public var metalDevice: MTLDevice!
    public var metalCommandQueue: MTLCommandQueue!
    
    // The Core Image pipeline.
    public var ciContext: CIContext!
    public var currentCIImage: CIImage? {
        didSet {
            cameraView.draw()
        }
    }
    
    // The capture session that provides video frames.
    public var session: AVCaptureSession?
    
    // MARK: - ViewController LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        arSession = ARSession()
//        arView = ARView()
        
        // Initialize and configure sceneView
//        sceneView = ARSCNView(frame: self.view.bounds)
//        sceneView.session = arSession // Assuming arSession is already configured
//        sceneView.automaticallyUpdatesLighting = true
//        self.view.addSubview(sceneView)
        
        setupARConfiguration()
        //initialize cameraView
        self.cameraView = MTKView(frame: view.bounds, device: MTLCreateSystemDefaultDevice())
        cameraView.delegate = self
        self.view.addSubview(cameraView)
        
        intializeRequests()
    }
    
    private func setupARConfiguration() {
        // setup arView
        arView = ARView(frame: self.view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(arView)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arSession.run(configuration)
        
    }
    
    deinit {
        session?.stopRunning()
    }
    
    // MARK: - Prepare Requests
    private func intializeRequests() {
        // clothing segmentation part
        let model = try! VNCoreMLModel(for: clothSegmentation(configuration: MLModelConfiguration()).model)
        self.clothesSegmentationRequest = VNCoreMLRequest(model: model)
    }
    
    private func getNewMaskCenter(from framePixelBuffer: CVPixelBuffer) -> CGPoint {
        // Create a CIImage from the frame pixel buffer
        let ciImage = CIImage(cvPixelBuffer: framePixelBuffer)
        
        // Create a VNImageRequestHandler with the CIImage
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try! handler.perform([clothesSegmentationRequest])
        
        // Extract the pixel buffer from the VNPixelBufferObservation
        if let result = clothesSegmentationRequest.results?.first as? VNPixelBufferObservation {
            let maskPixelBuffer = result.pixelBuffer
            return self.getCenterMask(from: maskPixelBuffer)
        } else {
            return .zero
        }
    }

    // MARK: - Perform processing
    private func processVideoFrame(_ framePixelBuffer: CVPixelBuffer) {
        
        frameCount += 1
            
        // Skip processing if the frame count is not at the desired interval
        if frameCount % frameSkipCount != 0 {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: framePixelBuffer)
        
        // Create a VNImageRequestHandler with the CIImage
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try! handler.perform([clothesSegmentationRequest])
        
        // Extract the pixel buffer from the VNPixelBufferObservation
        if let result = clothesSegmentationRequest.results?.first as? VNPixelBufferObservation {
            let maskPixelBuffer = result.pixelBuffer
            
            blend(original: framePixelBuffer, mask: maskPixelBuffer)
        }
        /*
        // find new center
        let newMaskCenter = getNewMaskCenter(from: framePixelBuffer)
            
        guard newMaskCenter != .zero, let frame = arSession.currentFrame else { return }
        
        let normalizedCenter = CGPoint(
                x: newMaskCenter.x,
                y: 1 - newMaskCenter.y // Flip y-axis for ARKit
        )
        
        // Perform a hit test at the 2D point to find a 3D anchor location
        guard let query = arView.session.currentFrame?.raycastQuery(from: normalizedCenter, allowing: .estimatedPlane, alignment: .any) else { return }
        
        let raycastResult = arSession.raycast(query)
        guard let firstResult = raycastResult.first else { return }

        // Safely unwrap and remove the existing anchor if it exists
        if let existingAnchor = self.anchor {
            arSession.remove(anchor: existingAnchor)
            print("Removed existing anchor.")
        }
        
        // Create and add a new anchor
        let newAnchor = ARAnchor(transform: firstResult.worldTransform)
        arSession.add(anchor: newAnchor) // This line needs the new anchor to be unwrapped
        self.anchor = newAnchor // Update self.anchor to the new anchor
        print("Anchor updated at new position")
        
        addRedCircleNode(to: newAnchor)
         */
        
    }
    
    // MARK: - Process Results
    
    // Performs the blend operation.
    private func blend(original framePixelBuffer: CVPixelBuffer,
                       mask maskPixelBuffer: CVPixelBuffer) {
        
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
        
        // Set the new, blended image as current.
        currentCIImage = blendFilter.outputImage?.oriented(.left)
    }
    
    private func addRedCircleNode(to anchor: ARAnchor) {
        let sphere = SCNSphere(radius: 0.02) // Adjust size as needed
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 0, 0) // Center it on the anchor

        sceneView.scene.rootNode.addChildNode(node) // Ensure sceneView is defined
    }
    
    // MARK - here we calculate the center point of clothing
    private func getCenterMask(from maskPixelBuffer: CVPixelBuffer) -> CGPoint {
  
        let maskWidth = CVPixelBufferGetWidth(maskPixelBuffer)
        let maskHeight = CVPixelBufferGetHeight(maskPixelBuffer)
        CVPixelBufferLockBaseAddress(maskPixelBuffer, .readOnly)
        guard let baseAddress = CVPixelBufferGetBaseAddress(maskPixelBuffer) else { return .zero }
        
        var totalX = 0
        var totalY = 0
        var pixelCount = 0

        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        for y in 0..<maskHeight {
            for x in 0..<maskWidth {
                let offset = y * maskWidth + x
                if buffer[offset] > 0 { // Clothing pixel
                    totalX += x
                    totalY += y
                    pixelCount += 1
                }
            }
        }
        CVPixelBufferUnlockBaseAddress(maskPixelBuffer, .readOnly)

        guard pixelCount > 0 else { return .zero } // No clothing pixels found
        let centerX = totalX / pixelCount
        let centerY = totalY / pixelCount

        let centerPoint = CGPoint(x: CGFloat(centerX) / CGFloat(maskWidth), y: CGFloat(centerY) / CGFloat(maskHeight))

        print("Center point: \(centerPoint)")
        
        return centerPoint
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ClothingSegmentationController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Grab the pixelbuffer frame from the camera output
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        processVideoFrame(pixelBuffer)
    }
}

extension ClothingSegmentationController {
    
    func setupMetal() {
        metalDevice = MTLCreateSystemDefaultDevice()
        metalCommandQueue = metalDevice.makeCommandQueue()
        
        cameraView.device = metalDevice
        cameraView.isPaused = true
        cameraView.enableSetNeedsDisplay = false
        cameraView.delegate = self
        cameraView.framebufferOnly = false
    }
    
    func setupCoreImage() {
        ciContext = CIContext(mtlDevice: metalDevice)
    }
    
    func setupCaptureSession() {
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            fatalError("Error getting AVCaptureDevice.")
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError("Error getting AVCaptureDeviceInput")
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.session = AVCaptureSession()
            self.session?.sessionPreset = .high
            self.session?.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(self, queue: .main)
            
            self.session?.addOutput(output)
            output.connections.first?.videoRotationAngle = 90
            self.session?.startRunning()
        }
    }
}

/// A structure that provides an RGB color intensity value for the roll, pitch, and yaw angles.
struct AngleColors {
    
    let red: CGFloat
    let blue: CGFloat
    let green: CGFloat
    
    init(roll: NSNumber?, pitch: NSNumber?, yaw: NSNumber?) {
        red = AngleColors.convert(value: roll, with: -.pi, and: .pi)
        blue = AngleColors.convert(value: pitch, with: -.pi / 2, and: .pi / 2)
        green = AngleColors.convert(value: yaw, with: -.pi / 2, and: .pi / 2)
    }
    
    static func convert(value: NSNumber?, with minValue: CGFloat, and maxValue: CGFloat) -> CGFloat {
        guard let value = value else { return 0 }
        let maxValue = maxValue * 0.8
        let minValue = minValue + (maxValue * 0.2)
        let facePoseRange = maxValue - minValue
        
        guard facePoseRange != 0 else { return 0 } // protect from zero division
        
        let colorRange: CGFloat = 1
        return (((CGFloat(truncating: value) - minValue) * colorRange) / facePoseRange)
    }
}

extension ClothingSegmentationController: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        // grab command buffer so we can encode instructions to GPU
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            return
        }

        // grab image
        guard let ciImage = currentCIImage else {
            return
        }

        // ensure drawable is free and not tied in the preivous drawing cycle
        guard let currentDrawable = view.currentDrawable else {
            return
        }
        
        // make sure the image is full screen
        let drawSize = cameraView.drawableSize
        let scaleX = drawSize.width / ciImage.extent.width
        let scaleY = drawSize.height / ciImage.extent.height
        
        let newImage = ciImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
        //render into the metal texture
        self.ciContext.render(newImage,
                              to: currentDrawable.texture,
                              commandBuffer: commandBuffer,
                              bounds: newImage.extent,
                              colorSpace: CGColorSpaceCreateDeviceRGB())

        // register drawwable to command buffer
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Delegate method not implemented.
    }
}



/*
 
 private func createColorfulNoiseAnimation() -> CIImage {
     let width: CGFloat = 640
     let height: CGFloat = 480
     let noiseFilter = CIFilter(name: "CIRandomGenerator")!

     // Generate noise
     guard let noiseImage = noiseFilter.outputImage?.cropped(to: CGRect(x: 0, y: 0, width: width, height: height)) else {
         return CIImage.empty() // Return an empty image if noise generation fails
     }

     // Create a color filter to apply to the noise
     let colorFilter = CIFilter(name: "CIColorMatrix")!
     colorFilter.setValue(noiseImage, forKey: kCIInputImageKey)

     // Generate animated colors based on time
     let time = CACurrentMediaTime()
     let red = (sin(time) + 1) / 2
     let green = (sin(time + .pi / 3) + 1) / 2
     let blue = (sin(time + 2 * .pi / 3) + 1) / 2

     // Set color matrix to colorize noise
     colorFilter.setValue(CIVector(x: red, y: 0, z: 0, w: 0), forKey: "inputRVector")
     colorFilter.setValue(CIVector(x: 0, y: green, z: 0, w: 0), forKey: "inputGVector")
     colorFilter.setValue(CIVector(x: 0, y: 0, z: blue, w: 0), forKey: "inputBVector")
     
     return colorFilter.outputImage!.cropped(to: CGRect(x: 0, y: 0, width: width, height: height))
 }
 
 private func blendAnimation(original framePixelBuffer: CVPixelBuffer,
                    mask maskPixelBuffer: CVPixelBuffer) {
     
     // Create CIImage objects for the video frame and the segmentation mask.
     let originalImage = CIImage(cvPixelBuffer: framePixelBuffer).oriented(.right)
     var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer).oriented(.right)

     // Scale the mask image to fit the bounds of the video frame.
     let scaleX = originalImage.extent.width / maskImage.extent.width
     let scaleY = originalImage.extent.height / maskImage.extent.height
     maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

     // Create the animated gradient
     let gradientImage = createColorfulNoiseAnimation()
     
     // Invert the mask image
     maskImage = maskImage.applyingFilter("CIColorInvert")
     
     // Blend the original, gradient, and mask images.
     let blendFilter = CIFilter.blendWithAlphaMask()
     blendFilter.inputImage = originalImage
     blendFilter.backgroundImage = gradientImage
     blendFilter.maskImage = maskImage
     
     // Set the new, blended image as current.
     currentCIImage = blendFilter.outputImage?.oriented(.left)
 }


 
 // MARK: - Process Results
 
 // Performs the blend operation.
 private func blend(original framePixelBuffer: CVPixelBuffer,
                    mask maskPixelBuffer: CVPixelBuffer) {
     
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
     
     // Set the new, blended image as current.
     currentCIImage = blendFilter.outputImage?.oriented(.left)
 }
 
 */
