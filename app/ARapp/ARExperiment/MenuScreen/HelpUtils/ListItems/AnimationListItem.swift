//
//  AnimationListItem.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import SwiftUI

import SwiftUI

struct AnimationListItem: View {
    @State private var selectedItem: Int? = nil
    private let items = [
        ListItem(id: 1, imageName: "photo", title: "First Song", subtitle: "Subtitle here"),
        ListItem(id: 2, imageName: "photo", title: "Second Song", subtitle: "Another subtitle"),
        ListItem(id: 3, imageName: "photo", title: "Third Song", subtitle: "More details here"),
        ListItem(id: 4, imageName: "photo", title: "Forth Song", subtitle: "Some details"),
        ListItem(id: 5, imageName: "photo", title: "Fifth Song", subtitle: "More details"),
        ListItem(id: 6, imageName: "photo", title: "Sixth Song", subtitle: "More details"),
        ListItem(id: 7, imageName: "photo", title: "Seventh Song", subtitle: "More details"),
    ]
    var onButtonCreatePressed: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 10) {
            CreateNewItemRowView(onCreate: onButtonCreatePressed)
            ForEach(items) { item in
                SelectableItemRowView(
                    item: item,
                    isSelected: selectedItem == item.id,
                    onSelect: { selectedItem = $0 }
                )
            }
        }
        .padding()
    }
}

// MARK: - Data Model
struct ListItem: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Selectable Item Row View
struct SelectableItemRowView: View {
    let item: ListItem
    let isSelected: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onSelect(item.id)
        }
    }
}


struct CreateNewItemRowView: View {
    var onCreate: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create")
                        .font(.headline)
                    Text("Add new designs to your library")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
//            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            //        .animation(.easeInOut(duration: 0.2), value: isSelected)
            .onTapGesture {
                onCreate()
            }
        }
    }
}




#Preview {
}
