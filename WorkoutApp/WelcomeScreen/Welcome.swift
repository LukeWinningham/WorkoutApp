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
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                welcomeSection
                VStack {
                    VStack {
                        Text("Welcome Back,").foregroundColor(.gray).font(.title3)
                            .bold()
                        Text("Luke").foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255)).font(.largeTitle)
                            .bold()
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
                        .foregroundColor(Color(red: 0.067, green: 0.69, blue: 0.951))
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
                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                   
                    .frame(width: 50, height: 50)
                    .imageScale(.small)
            }
            Spacer()
            Button(action: { showingAddView = true }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                    .frame(width: 50, height: 50)
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
