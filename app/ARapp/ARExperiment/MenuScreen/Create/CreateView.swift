//
//  CreateView.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import SwiftUI

struct CreateView: View {
    var body: some View {
        VStack(spacing: 0) { // Zero spacing to tightly control layout
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Create")
                        .font(.title)
                        .fontWeight(.semibold)

                    Image(systemName: "plus.square.on.square")
                        .font(.title) // Match the text size
                        .foregroundColor(.yellow)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                // Custom bounce effect
                            }
                        }
                }
                .padding()

            }
            
            // Dynamic Content
            ScrollView {
                // ADD HERE THE CODE
            }
        }
    }
}

#Preview {
    CreateView()
}
