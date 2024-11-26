//
//  AnimationHandler.swift
//  ARExperiment
//
//  Created by David Drobny on 12/11/2024.
//

import ARKit

protocol AnimationHandler {
    @discardableResult
    func setupLoadingPlayer() -> AnimationHandler
    @discardableResult
    func setupVideoPlayer() -> AnimationHandler
    @discardableResult
    func setAuthorName() -> AnimationHandler
    
//    func setMaterial()
    @discardableResult
    func updateAnimation() -> AnimationHandler
    
    @discardableResult
    func placeContent(in imageAnchor : ARImageAnchor, with node: SCNNode) -> AnimationHandler
}
