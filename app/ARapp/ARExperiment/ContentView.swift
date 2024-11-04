//
//  ContentView.swift
//  ARExperiment
//
//  Created by David Drobny on 14/09/2024.
//

import SwiftUI
import ARKit
import RealityKit


struct ContentView: View {
    @State private var showSheet: Bool = false
    @State private var activeTab: Tab = .designs
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // AR Session
            ARViewContainerConverter<DynamicReferenceController>().edgesIgnoringSafeArea(.all)
            
            // Main menu
            TabBarView(activeTab: $activeTab)
        }
        .task {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SheetContentView(activeTab: $activeTab)
        }
    }
}
