//
//  LiveActivity.swift
//  Amson
//
//  Created by Luke Winningham on 3/4/24.
//

import SwiftUI
import Combine
import CloudKit
import ActivityKit
import WidgetKit


struct WorkoutAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var exerciseName: String
        var currentSet: Int
        var totalSets: Int
        var repsPerSet: [Int]
    }
}
struct WorkoutLiveActivityView: View {
    var exerciseName: String
    @State private var currentSet: Int
    var totalSets: Int
    var repsPerSet: [Int]
    var currentActivity: Activity<WorkoutAttributes>?
    @State private var currentReps = 0

    init(context: ActivityViewContext<WorkoutAttributes>, currentActivity: Activity<WorkoutAttributes>?) {
        self.exerciseName = context.state.exerciseName
        self.currentSet = context.state.currentSet
        self.totalSets = context.state.totalSets
        self.repsPerSet = context.state.repsPerSet
        self.currentActivity = currentActivity
        
        // Fetch reps data from CloudKit
        fetchRepsDataFromCloudKit()
        
        _currentReps = State(initialValue: context.state.repsPerSet[context.state.currentSet - 1])
    }
    
    init(exerciseName: String, currentSet: Int, totalSets: Int, repsPerSet: [Int], currentActivity: Activity<WorkoutAttributes>?) {
        self.exerciseName = exerciseName
        self.currentSet = currentSet
        self.totalSets = totalSets
        self.repsPerSet = repsPerSet
        self.currentActivity = currentActivity
        
        // Fetch reps data from CloudKit
        fetchRepsDataFromCloudKit()
        
        _currentReps = State(initialValue: repsPerSet[currentSet - 1])
    }
    
    var body: some View {
        VStack {
            Text(exerciseName)
                .foregroundColor(.white)
            Text("Set \(currentSet) of \(totalSets)")
                .foregroundColor(.white)
            
            Text("Reps: \(currentReps)") // Display reps fetched from CloudKit
            
            HStack {
                Button(action: {
                    goToPrevious() // Call goToPrevious function when left arrow is tapped
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    goToNext() // Call goToNext function when right arrow is tapped
                }) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.black)
        .cornerRadius(10)
        .onAppear {
            fetchRepsDataFromCloudKit()
        }
    }

    private func fetchRepsDataFromCloudKit() {
        // Fetch reps data from CloudKit here and assign it to currentReps
        // Example:
        // currentReps = // Data fetched from CloudKit
    }

    private func goToNext() {
        let nextSet = currentSet + 1
        if nextSet <= totalSets {
            currentSet = nextSet
            // Assign reps for next set from repsPerSet array or fetch from CloudKit if necessary
            currentReps = repsPerSet[nextSet - 1]
        }
        
        updateLiveActivity()
    }

    private func goToPrevious() {
        let previousSet = currentSet - 1
        if previousSet >= 1 {
            currentSet = previousSet
            // Assign reps for previous set from repsPerSet array or fetch from CloudKit if necessary
            currentReps = repsPerSet[previousSet - 1]
        }
        
        updateLiveActivity()
    }

    private func updateLiveActivity() {
        let newContentState = WorkoutAttributes.ContentState(
            exerciseName: exerciseName,
            currentSet: currentSet,
            totalSets: totalSets,
            repsPerSet: repsPerSet
        )
        
        Task {
            await currentActivity?.update(using: newContentState)
        }
    }
}

struct WorkoutLiveActivityView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutLiveActivityView(exerciseName: "Push-ups", currentSet: 1, totalSets: 3, repsPerSet: [10, 12, 15], currentActivity: nil)
    }
}
