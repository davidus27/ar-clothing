//
//  TabView.swift
//  ARExperiment
//
//  Created by David Drobny on 27/09/2024.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case designs = "My designs"
    case marketPlace = "Marketplace"
    case settings = "Settings"
    case profile = "Me"
    
    var symbol: String {
        switch self {
        case .designs:
            return "heart.circle"
        case .marketPlace:
            return "cart"
        case .settings:
            return "gear"
        case .profile:
            return "person.crop.circle"
        }
    }
}
