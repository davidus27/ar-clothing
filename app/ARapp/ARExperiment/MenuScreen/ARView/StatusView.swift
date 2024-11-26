//
//  StatusView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/11/2024.
//

import SwiftUI

struct StatusView: View {
    @Binding var appState: String
    
    var body: some View {
        VStack {
            HStack {
                Text(appState)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.leading, 16)
                    .padding(.top, 16)
                Spacer()
            }
            Spacer()
        }
    }
}
