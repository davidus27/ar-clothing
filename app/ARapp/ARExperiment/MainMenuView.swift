//
//  MainMenuView.swift
//  ARExperiment
//
//  Created by David Drobny on 27/09/2024.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showSheet: Bool = false
    @State private var activeTab: Tab = .designs
    // var view: any View
    
//    init(view: any View) {
//        self.view = view
//    }
 
    
    var body: some View {
        ZStack(alignment: .bottom) {
             ARViewContainer().edgesIgnoringSafeArea(.all)
            
            TabBar()
                .frame(height: 49)
                .background(.regularMaterial)
        }
        .task {
            showSheet = true
        }
        .sheet(isPresented: $showSheet, content: {
            VStack(alignment: .leading, spacing: 10, content: {
                Text(activeTab.rawValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // implement view based on the tab
                switch activeTab {
                    case .designs:
                        DesignsView()
                    case .marketPlace:
                        MarketPlaceView()
                    case .settings:
                        SettingsView()
                    case .profile:
                        ProfileView()
                }
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
        })
    }
    
    @ViewBuilder
    func TabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) {
                tab in Button(action: { activeTab = tab}, label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.symbol)
                            .font(.title2)
                        Text(tab.rawValue)
                            .font(.caption2)
                    }
                    .foregroundColor(activeTab == tab ? Color.accentColor : .gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                })
            }
        }
    }
    
}

#Preview {
    MainMenuView()
}
