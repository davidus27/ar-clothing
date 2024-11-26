//
//  AnimationListItem.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//

import SwiftUI

struct AnimationListItem: View {
    @State private var isLoading = true
    private let items = [
        ListItem(id: 1, imageName: "photo", title: "First Song", subtitle: "Subtitle here"),
        ListItem(id: 2, imageName: "photo", title: "Second Song", subtitle: "Another subtitle"),
        ListItem(id: 3, imageName: "photo", title: "Third Song", subtitle: "More details here")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items) { item in
                        if isLoading {
                            LoadingRowView()
                        } else {
                            ItemRowView(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Spotify Style List")
            .onAppear {
                // Simulate loading delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Data Model
struct ListItem: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Item Row View
struct ItemRowView: View {
    let item: ListItem
    
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
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Loading Row View with Shimmer Effect
struct LoadingRowView: View {
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .shimmerEffect(isAnimating: shimmer)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .shimmerEffect(isAnimating: shimmer)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .shimmerEffect(isAnimating: shimmer)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            shimmer = true
        }
    }
}

// MARK: - Shimmer Effect Modifier
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    var isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.4), .clear]),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: isAnimating ? phase : -UIScreen.main.bounds.width)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            phase = UIScreen.main.bounds.width
                        }
                    }
            )
            .mask(content)
    }
}

extension View {
    func shimmerEffect(isAnimating: Bool) -> some View {
        self.modifier(ShimmerEffect(isAnimating: isAnimating))
    }
}
