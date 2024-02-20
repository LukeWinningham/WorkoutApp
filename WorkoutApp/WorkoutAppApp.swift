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
    @StateObject private var viewModel = ExercisesViewModel() // Manage exercises data
    @StateObject private var packViewModel = PackViewModel()


    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isUserAuthenticated {
                    if authViewModel.isProfileCompleted {
                        NavBar() // Your authenticated and profile completed view
                            .environmentObject(viewModel) // Provide viewModel to your views
                            .environmentObject(workoutData) // Provide workoutData to your views
                            .environmentObject(navigationState) // Provide navigationState to your views
                            .environmentObject(packViewModel)
                            .environmentObject(authViewModel) // Ensure PersonalData can update the authViewModel

                    } else {
                        PersonalData() // Show the PersonalData view if the profile is not completed
                            .environmentObject(authViewModel) // Ensure PersonalData can update the authViewModel
                    }
                } else {
                    LogOn()
                        .environmentObject(authViewModel) // Provide authViewModel to your LogOn view
                }
            }
        }
    }
}
