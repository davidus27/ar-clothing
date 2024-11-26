//
//  HelpMenuButton.swift
//  ARExperiment
//
//  Created by David Drobny on 26/11/2024.
//

import SwiftUI

struct HelpMenuButton: View {
    var onReset: () -> Void // Callback for resetting ar session
    var onHelp: () -> Void // callback for help needed
    @State private var showMenu: Bool = false // State to show/hide menu

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Menu {
                    Button(action: onHelp) {
                        Image(systemName: "info.circle")
                        Text("Show App Guide")
                    }
                    
                    Button(action: onReset) {
                        Image(systemName: "trash")
                        Text("Reset AR Session")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(5) // Adds tappable padding around the icon
                        .background(Color.clear) // Ensures no visual change
                        .contentShape(Rectangle()) // Makes the whole padding tappable
                }
                .padding(.trailing, 16)
                .padding(.top, 16)
            }
            Spacer()
        }
    }
}
