//
//  Welcome.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct Welcome: View {
    @EnvironmentObject var navigationState: NavigationState


    @EnvironmentObject var weekData: WeekData
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment
    @State private var showingAddView = false
    @State private var selectedExerciseIndex: Int?

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                welcomeSection
                VStack {
                    VStack {
                        Text("Welcome Back,")
                            .font(.title3)
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))

                            .bold()
                        Text("Luke")
                            .font(.system(size:50))
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))                            .bold()
                        
                    }
                }
                Spacer()
                // Check the value of workoutData.done
                if workoutData.done == 2 {
                    // Show an image when workoutData.done equals 2
                    Image("Image") // Make sure to replace "YourImage" with the actual name of your image in the asset catalog
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("Great Job! You CRUSHED It Today.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .bold()
                } else {
                    // show rectangle and name of the wokrout day
                    TodaysWorkout()
                }
                Spacer()
                VStack{
                    FriendActivity()
                        
                }
            }
        }
    }

    private var welcomeSection: some View {
        HStack {
            VStack{
                Image("Logo")
                    .frame(width: 50, height: 50)
                    .imageScale(.small)
            }
            Spacer()
            Button(action: { showingAddView = true }) {
                Image(systemName: "magnifyingglass")
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))

                    .imageScale(.large)
            }
            .sheet(isPresented: $showingAddView) {
                AddView(weekData: _weekData)
            }
        }
        .padding()
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize your environment objects
        let weekData = WeekData.shared
        let workoutData = WorkoutData()
        NavigationView {
            // Provide the environment objects to ContentView
            Welcome()
                .environmentObject(weekData)
                .environmentObject(workoutData)
        }
    }
}
