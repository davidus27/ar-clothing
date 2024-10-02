//
//  TabView.swift
//  ARExperiment
//
//  Created by David Drobny on 02/10/2024.
//

import SwiftUI

struct SheetContentView: View {
    @Binding var activeTab: Tab
    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(activeTab.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
            
            //                switch activeTab {
            //                    case .designs:
            //                        DesignsView()
            //                    case .marketPlace:
            //                        MarketPlaceView()
            //                    case .settings:
            //                        SettingsView()
            //                    case .profile:
            //                        ProfileView()
            //                }
        })
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .presentationDetents([.height(60), .medium, .large])
        .presentationCornerRadius(20)
        .presentationBackground(.regularMaterial)
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .bottomMaskForSheet()
    }
}
