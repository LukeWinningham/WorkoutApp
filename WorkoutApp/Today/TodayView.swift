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
    @Environment(\.presentationMode) var presentationMode

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
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.backward.circle.fill")
                    .imageScale(.medium)
                    .font(.title)
                    .foregroundColor(Color(hue: 0.014, saturation: 0.483, brightness: 0.901))
            }
            .padding(.leading, 15.0)
            
            
          Spacer()
        }
        
        
        
    }

   


}
    struct Today_Previews: PreviewProvider {
        static var previews: some View {
            TodayView()
                .environmentObject(WeekData.shared)
                .environmentObject(WorkoutData())
        }
    }
