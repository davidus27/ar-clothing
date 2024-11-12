//
//  CommunicationHandler.swift
//  ARExperiment
//
//  Created by David Drobny on 12/11/2024.
//

import ARKit

protocol CommunicationHandler {
    func updateReferenceImage(to image: UIImage?)
    func updateAnimation() // changes the material based on the input, either video, url, or resource
}
