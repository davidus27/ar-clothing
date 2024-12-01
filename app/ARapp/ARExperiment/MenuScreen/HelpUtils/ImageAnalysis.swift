//
//  ImageAnalysis.swift
//  ARExperiment
//
//  Created by David Drobny on 30/11/2024.
//

import UIKit
import CoreImage
import CoreGraphics

// Function to calculate the histogram of an image
func calculateHistogram(for image: UIImage) -> [Int] {
    guard let cgImage = image.cgImage else { return [] }
    
    let context = CIContext(options: nil)
    let ciImage = CIImage(cgImage: cgImage)
    
    // Convert image to grayscale using a CIColorControls filter
    guard let filter = CIFilter(name: "CIColorControls") else { return [] }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(0.0, forKey: kCIInputSaturationKey) // Remove color
    
    guard let outputImage = filter.outputImage else { return [] }
    
    // Create histogram with the grayscale image
    guard let histogramFilter = CIFilter(name: "CIAreaHistogram") else { return [] }
    histogramFilter.setValue(outputImage, forKey: kCIInputImageKey)
    histogramFilter.setValue(CIVector(x: 0, y: 0, z: CGFloat(cgImage.width), w: CGFloat(cgImage.height)), forKey: kCIInputExtentKey)
    
    guard let outputHistogramImage = histogramFilter.outputImage else { return [] }
    
    // Extract histogram data
    let bitmap = context.createCGImage(outputHistogramImage, from: outputHistogramImage.extent)
    guard let pixelData = bitmap?.dataProvider?.data else { return [] }
    let ptr = CFDataGetBytePtr(pixelData)
    
    var histogram = [Int](repeating: 0, count: 256)
    
    // Safely unwrap width and height of the bitmap
    if let width = bitmap?.width, let height = bitmap?.height {
        let count = width * height
        for i in 0..<count {
            let pixel = ptr?[i] ?? 0  // Get pixel value (UInt8)
            let pixelIndex = Int(pixel)  // Convert to Int for use as array index
            histogram[pixelIndex] += 1
        }
    } else {
        print("Failed to retrieve image dimensions.")
    }
    
    return histogram
}

// Function to evaluate the image's histogram distribution
func isHistogramDistributionGood(image: UIImage) -> Bool {
    let histogram = calculateHistogram(for: image)
    
    // Calculate the "spread" of the histogram by finding the difference between the highest and lowest values
    let min = histogram.min() ?? 0
    let max = histogram.max() ?? 0
    
    // Check the spread of the histogram (i.e., a flat histogram is good)
    let spread = max - min
    return spread > 50 // Threshold value; adjust based on your needs
}

// MARK: - Check Image Resolution
func isResolutionSufficient(image: UIImage) -> Bool {
    let width = image.size.width
    let height = image.size.height
    print(width , height)
    return width >= 480 && height >= 480
}

// MARK: - Check for Low Local Contrast (Uniform Color Regions)
func hasLowLocalContrast(image: UIImage) -> Bool {
    guard let cgImage = image.cgImage else { return true }

    let context = CIContext(options: nil)
    let ciImage = CIImage(cgImage: cgImage)

    // Convert image to grayscale
    guard let filter = CIFilter(name: "CIColorControls") else { return true }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(0.0, forKey: kCIInputSaturationKey)
    guard let outputImage = filter.outputImage else { return true }
    
    // Compute standard deviation of pixel values
    guard let histogramFilter = CIFilter(name: "CIAreaHistogram") else { return true }
    histogramFilter.setValue(outputImage, forKey: kCIInputImageKey)
    histogramFilter.setValue(CIVector(x: 0, y: 0, z: CGFloat(cgImage.width), w: CGFloat(cgImage.height)), forKey: kCIInputExtentKey)
    guard let outputHistogramImage = histogramFilter.outputImage else { return true }
    
    let bitmap = context.createCGImage(outputHistogramImage, from: outputHistogramImage.extent)
    guard let pixelData = bitmap?.dataProvider?.data else { return true }
    let ptr = CFDataGetBytePtr(pixelData)

    var pixelIntensities = [Int]()
    for i in 0..<bitmap!.width * bitmap!.height {
        let pixel = ptr?[i] ?? 0
        pixelIntensities.append(Int(pixel))
    }

    let mean = pixelIntensities.reduce(0, +) / pixelIntensities.count
    let variance = pixelIntensities.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / pixelIntensities.count
    let standardDeviation = sqrt(Double(variance))
    
    // If the standard deviation is low, it has low local contrast
    return standardDeviation < 30.0 // You can adjust this threshold based on testing
}

// MARK: - Check for Low Texture
func hasLowTexture(image: UIImage) -> Bool {
    guard let cgImage = image.cgImage else { return true }
    
    let context = CIContext(options: nil)
    let ciImage = CIImage(cgImage: cgImage)
    
    // Apply Sobel filter to detect edges (texture)
    guard let filter = CIFilter(name: "CISobelEdgeDetection") else { return true }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    guard let outputImage = filter.outputImage else { return true }

    // Compute the number of edge pixels
    let bitmap = context.createCGImage(outputImage, from: outputImage.extent)
    guard let pixelData = bitmap?.dataProvider?.data else { return true }
    let ptr = CFDataGetBytePtr(pixelData)

    var edgePixelCount = 0
    let totalPixels = bitmap!.width * bitmap!.height
    for i in 0..<totalPixels {
        if ptr?[i] ?? 0 > 128 { // Edge detection threshold
            edgePixelCount += 1
        }
    }

    // If edge pixel count is low, it means the image has low texture
    let textureRatio = Double(edgePixelCount) / Double(totalPixels)
    return textureRatio < 0.1 // Adjust the threshold based on your needs
}
