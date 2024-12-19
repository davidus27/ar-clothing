//
//  TestController.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import UIKit
import ARKit

import UIKit

class TestController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color for visibility while debugging (optional)
        view.backgroundColor = .white
        
        // Load the image
        let imageView = UIImageView()
        if let image = UIImage(named: "background.HEIC") {
            imageView.image = image
        } else {
            print("Error: Image 'background.HEIC' not found.")
        }
        
        // Configure the image view
        imageView.contentMode = .scaleAspectFill // Adjusts how the image fits the screen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the image view to the view hierarchy
        view.addSubview(imageView)
        
        // Constrain the image view to fill the entire screen
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


#Preview {
    TestController()
}
