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
        externalSource: "http://192.168.0.118:8000",
        appStatus: "Initializing...",
        userId: "67582f2fbdad884371e8fdc1",
        authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzU4MmYyZmJkYWQ4ODQzNzFlOGZkYzEiLCJpYXQiOjE3MzM4MzI0OTV9.3zV4UplyaeiwPGoG9AXeW2sX3jnqs7SY4iXT_mf5XBI"
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
