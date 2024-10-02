//
//  TabBarView.swift
//  ARExperiment
//
//  Created by David Drobny on 02/10/2024.
//

import SwiftUI

struct TabBarView: View {
    @Binding var activeTab: Tab
    var body: some View {
        TabBar()
            .frame(height: 49)
            .background(.regularMaterial)
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
