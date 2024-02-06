//
//  ContentView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/29/24.
//

import SwiftUI
import Combine

struct ContentView: View {

//This view is the list of workouts the user has
    
    
    
    var body: some View {
        TodayView()
    }
}

  


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize your environment objects
        let weekData = WeekData.shared
        let workoutData = WorkoutData()

        // Provide the environment objects to ContentView
        ContentView()
            .environmentObject(weekData)
            .environmentObject(workoutData)
    }
}
