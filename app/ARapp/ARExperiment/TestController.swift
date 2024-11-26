//
//  TestController.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import UIKit
import ARKit

class TestController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color for visibility (optional)
        view.backgroundColor = .white
        
        // Create the UILabel
        let label = UILabel()
        label.text = "This is AR view!"
        label.textColor = .black     // Text color
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24) // Adjust font size
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the view
        view.addSubview(label)
        
        // Center the label in the view
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

#Preview {
    TestController()
}