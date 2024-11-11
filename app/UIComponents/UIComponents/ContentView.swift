//
//  ContentView.swift
//  UIComponents
//
//  Created by David Drobny on 11/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State var selectedImage: UIImage?
    var body: some View {
        TakingImagesSelection(selectedImage: $selectedImage)
    }
}

#Preview {
    ContentView()
}
