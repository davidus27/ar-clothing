//
//  SettingsView.swift
//  ARExperiment
//
//  Created by David Drobny on 26/09/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            Text("Settings view")
        }
    }
}

#Preview {
    SettingsView()
}
