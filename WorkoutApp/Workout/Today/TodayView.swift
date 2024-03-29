//
//  TodayView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct TodayView: View {
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment
    @State private var showingAddView = false
    @State private var showingExerciseView = false
    @State private var selectedExerciseIndex: Int?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
            VStack {
                welcomeSection
                    NameOfDay()
                    // Otherwise, show today's tasks
         //           WorkoutList()
                 //   StartButton()
                

                Spacer()
            }
        }
    }

    private var welcomeSection: some View {
        
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.backward")
                    .imageScale(.small)
                    .font(.title)
                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                    .shadow(radius: 3)
            }
            .padding(.leading, 15.0)
            
            
          Spacer()
        }
        
        
        
    }

   


}
    struct Today_Previews: PreviewProvider {
        static var previews: some View {
            TodayView()
                .environmentObject(WorkoutData())
        }
    }
