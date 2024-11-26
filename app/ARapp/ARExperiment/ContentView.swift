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
    @State private var activeTab: TabOption = .explore // default selected view at the start
    @State private var sheetHeight = 0.0
    @State private var isGuideShown: Bool = false // this will normally be set to true
    @State private var appStatus: String = "Initializing..."
    
    var body: some View {
        if isGuideShown {
            AppGuideView(isGuideShown: $isGuideShown)
        }
        else {
            ZStack(alignment: .bottom) {
                MainARView(isGuideShown: $isGuideShown, appStatus: $appStatus)
                
                // Main menu
                TabBarView(activeTab: $activeTab)
            }
            .task {
                appStatus = "Ready to explore"
                showSheet = true
            }
            .sheet(isPresented: $showSheet) {
                SheetContentView(activeTab: $activeTab)
            }
        }
    }
}

#Preview {
    ContentView()
}
