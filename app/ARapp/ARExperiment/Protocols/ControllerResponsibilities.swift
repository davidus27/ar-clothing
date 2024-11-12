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
}


