//
//  CommunicationHandler.swift
//  ARExperiment
//
//  Created by David Drobny on 12/11/2024.
//

import ARKit

protocol CommunicationHandler {
    @discardableResult
    func updateReferenceImage(to image: UIImage?) -> CommunicationHandler
    @discardableResult
    func updateAnimation() -> CommunicationHandler // changes the material based on the input, either video, url, or resource
}
