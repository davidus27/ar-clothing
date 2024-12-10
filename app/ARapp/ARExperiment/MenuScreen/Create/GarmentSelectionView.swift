//
//  GarmentSelectionView.swift
//  ARExperiment
//
//  Created by David Drobny on 01/12/2024.
//

import SwiftUI

struct GarmentSelectionView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @Binding var selectedGarment: LinkedGarmentData?
    @Binding var selectedMode: String

    var body: some View {
        VStack {
            if filteredGarments.isEmpty {
                Text("No garments available for \(selectedMode)")
                    .foregroundColor(.gray)
                    .font(.headline)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredGarments) { garment in
                            GarmentCardView(
                                garment: garment,
                                isSelected: selectedGarment?.id == garment.id
                            )
                            .onTapGesture {
                                selectedGarment = garment
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("Select a \(selectedMode)")
    }

    private var filteredGarments: [LinkedGarmentData] {
        userDataStore.user.garments.filter { garment in
            garmentType(from: garment.uid) == selectedMode
        }
    }

    private func garmentType(from uid: String) -> String {
        let prefix = String(uid.prefix(2))
        switch prefix {
        case "je": return "Japanese Edition"
        case "pe": return "Password Edition"
        default: return "Unknown Type"
        }
    }
}

struct GarmentCardView: View {
    var garment: LinkedGarmentData
    var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(garment.name)
                .font(.headline)
                .foregroundColor(.primary)

            Text(garmentType(from: garment.uid))
                .font(.subheadline)
                .foregroundColor(.secondary)

            if isSelected {
                Text(garment.uid)
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .opacity(0.8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // Full-width card
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: 2)
        )
    }

    private func garmentType(from uid: String) -> String {
        let prefix = String(uid.prefix(2))
        switch prefix {
        case "je": return "Japanese Edition"
        case "pe": return "Password Edition"
        default: return "Unknown Type"
        }
    }
}
