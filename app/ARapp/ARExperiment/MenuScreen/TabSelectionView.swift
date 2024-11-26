//
//  TabSelectionView.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import SwiftUI

struct TabSelectionView: View {
    @Binding var tabNames: [String]
    @State var selectedTab: Int = 0

    var body: some View {
        HStack {
            ForEach(0..<tabNames.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack {
                        Text(tabNames[index])
                            .font(.headline)
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(selectedTab == index ? .blue : .clear)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
