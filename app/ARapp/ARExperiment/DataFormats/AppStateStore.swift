//
//  AppStateStore.swift
//  ARExperiment
//
//  Created by David Drobny on 09/12/2024.
//

import SwiftUI
import Combine

struct AppState {
    var value: Int
    var externalSource: String
    var appStatus: String
    var userId: String
    var authToken: String
    
    // mockup user
    static let initialState: AppState = .init(
        value: 0,
        externalSource: "http://192.168.1.191:8000",
        appStatus: "Initializing...",
        userId: "6766eda5ae90948e331e4a86",
        authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzY2ZWRhNWFlOTA5NDhlMzMxZTRhODYiLCJpYXQiOjE3MzQ3OTg3NTd9.CcEN-NH-OvuBEC4MDHSEockfLuITpcCe-S6msPmzC_Q"
    )
}

class AppStateStore: ObservableObject {
    @Published var state: AppState
    
    init() {
        self.state = AppState.initialState
    }
    
    public var didFail: Bool = false
    
    // Example function for fetching user data from a REST API
    func fetchAppState() {
        
    }
    
    var userAddress: String {
        return "\(state.externalSource)/users/\(state.userId)"
    }
    
    var animationAddress: String {
        return "\(state.externalSource)/animations/"
    }

}
