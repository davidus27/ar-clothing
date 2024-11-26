//
//  ARInitializable.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//

import ARKit

protocol ARInitializable {
    @discardableResult
    func initializeScene(view: UIView, to: ARSCNViewDelegate) -> ARInitializable
    @discardableResult
    func setupARView() -> ARInitializable
    
    @discardableResult
    func updateReferenceImage(to image: UIImage?) -> ARInitializable
    
    @discardableResult
    // Function to add a marker for the image anchor
    func addAnchorMarker(for imageAnchor: ARImageAnchor, to node: SCNNode) -> ARInitializable
    
    @discardableResult
    // Function to add a marker for the body anchor
    func addBodyAnchorMarker(for bodyAnchor: ARBodyAnchor) -> ARInitializable
}


