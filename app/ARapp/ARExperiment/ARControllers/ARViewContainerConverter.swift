//
//  ARViewContainerConverter.swift
//  ARExperiment
//
//  Created by David Drobny on 02/10/2024.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewContainerConverter<Controller: UIViewController>: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        return Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}
}

