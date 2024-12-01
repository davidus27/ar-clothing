//
//  TabView.swift
//  ARExperiment
//
//  Created by David Drobny on 27/09/2024.
//

import SwiftUI

enum TabOption: String, CaseIterable {
    case library = "My library"
    case explore = "Explore"
    case create = "Create design"
    case settings = "Settings"
    case profile = "Me"
    
    var symbol: String {
        switch self {
        case .library:
            return "heart.circle"
        case .explore:
            return "sparkle.magnifyingglass"
        case .create:
            return "plus.app"
        case .settings:
            return "gear"
        case .profile:
            return "person.crop.circle"
        }
    }
}
