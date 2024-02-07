//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/29/24.
//

import SwiftUI
import Combine
@main
struct WorkoutAppApp: App {
    @StateObject private var authViewModel = AuthViewModel() // Manage authentication state
    @StateObject private var workoutData = WorkoutData() // Instantiate your shared data model
    @StateObject private var navigationState = NavigationState() // Manage navigation state

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isUserAuthenticated {
                    NavBar() // Your authenticated view
                        .environmentObject(workoutData) // Provide workoutData to your views
                        .environmentObject(navigationState) // Provide navigationState to your views
                } else {
                    LogOn()
                        .environmentObject(authViewModel) // Provide authViewModel to your LogOn view
                }
                
            }
            
            .environmentObject(WeekData.shared) // Inject WeekData.shared as an Environment Object
        }
    }
}
