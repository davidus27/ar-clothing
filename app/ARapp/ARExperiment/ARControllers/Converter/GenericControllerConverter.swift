//
//  GenericControllerConverter.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//
import SwiftUI

struct GenericControllerConverter<T: UIViewController, U>: UIViewControllerRepresentable {
    
    // The binding variable to pass to the UIViewController
    @Binding var bindingValue: U
    
    // The function to update the UIViewController with the new data
    var updateUIViewController: (T, U) -> Void
    
    // The function to create the UIViewController instance
    var makeUIViewController: () -> T
    
    // Initializer
    init(bindingValue: Binding<U>, makeUIViewController: @escaping () -> T, updateUIViewController: @escaping (T, U) -> Void) {
        self._bindingValue = bindingValue
        self.makeUIViewController = makeUIViewController
        self.updateUIViewController = updateUIViewController
    }
    
    func makeUIViewController(context: Context) -> T {
        return makeUIViewController()
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        updateUIViewController(uiViewController, bindingValue)
    }
}


