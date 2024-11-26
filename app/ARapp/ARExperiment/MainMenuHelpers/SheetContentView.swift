//
//  SheetContentView.swift
//  ARExperiment
//
//  Created by David Drobny on 02/10/2024.
//

import SwiftUI

struct SheetContentView: View {
    @Binding var activeTab: TabOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            switch activeTab {
            case .library:
                LibraryView()
            case .explore:
                ExploreView()
            case .settings:
                SettingsView()
            case .profile:
                ProfileView()
            case .add:
                CreateView()
            }
        })
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .presentationDetents([.height(110), .medium, .large ])
        .presentationCornerRadius(20)
        .presentationBackground(.regularMaterial)
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .bottomMaskForSheet()
    }
}
