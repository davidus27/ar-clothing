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
        userId: "6768caff4f89f84e6fb5c926",
        authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzY4Y2FmZjRmODlmODRlNmZiNWM5MjYiLCJpYXQiOjE3MzQ5MjA5NTl9.IgiGhW9r4uvS74DZHJTsCgHxwqW5yQ5vPsd5xoaXUw4"
    )
    
    
    var userAddress: String {
        return "\(externalSource)/users/\(userId)"
    }
    
    var animationAddress: String {
        return "\(externalSource)/animations/"
    }
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
