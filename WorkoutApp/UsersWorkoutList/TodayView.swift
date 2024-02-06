//
//  TodayView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct TodayView: View {
    @EnvironmentObject var weekData: WeekData
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment
    @State private var showingAddView = false
    @State private var showingExerciseView = false
    @State private var selectedExerciseIndex: Int?

    var body: some View {
        ZStack {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
            VStack {
                welcomeSection
                NameOfDay()
            
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
                    // Otherwise, show today's tasks
                    WorkoutList()
                    StartButton()
                }

                Spacer()
            }
        }
    }

    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome Back,").foregroundColor(.gray).font(.body)
                Text("Luke").foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255)).font(.title).bold()
            }
            Spacer()
            Button(action: { showingAddView = true }) {
                Image(systemName: "plus.circle.fill")
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
    struct Today_Previews: PreviewProvider {
        static var previews: some View {
            TodayView()
                .environmentObject(WeekData.shared)
                .environmentObject(WorkoutData())
        }
    }
