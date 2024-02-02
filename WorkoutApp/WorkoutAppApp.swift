//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/29/24.
//

import SwiftUI

@main
struct WorkoutAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // Initialize ContentView
                .environmentObject(WeekData.shared) // Inject WeekData.shared as an Environment Object
        }
    }
}
