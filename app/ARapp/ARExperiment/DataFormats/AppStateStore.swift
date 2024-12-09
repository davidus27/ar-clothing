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
        externalSource: "http://localhost:8000",
        appStatus: "Initializing...",
        userId: "6755c9940385d641f334638f",
        authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzU1Yzk5NDAzODVkNjQxZjMzNDYzOGYiLCJpYXQiOjE3MzM2NzU0MTJ9.az7hekF17QU89OTMtDYHs1N-RuIUBOOXzE_2_v6RJgM"
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

}
