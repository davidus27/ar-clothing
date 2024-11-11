//
//  TestingController.swift
//  ARExperiment
//
//  Created by David Drobny on 11/11/2024.
//

import SwiftUI

class TestingController: UIViewController {
    var selectedImage: UIImage? {
        didSet {
            print("Updated image on TestingController!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

struct TestingView: View {
    var body: some View {
        Text("Hello, World!").font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { TestingView() }
}

#Preview {
    TestingView()
        .onAppear {
            print("Fuuuuck")
        }
}
