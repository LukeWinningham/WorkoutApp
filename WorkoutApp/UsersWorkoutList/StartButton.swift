//
//  StartButton.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct StartButton: View {
    @EnvironmentObject var weekData: WeekData
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment

    var body: some View {
        Group {
            if let todayTasks = weekData.days.first(where: { $0.name == getCurrentDay() }), !todayTasks.items.isEmpty{
                // Only show the "Start Workout" button if there are workouts for today
                NavigationLink(destination: WorkoutDetails().environmentObject(weekData).environmentObject(WorkoutData())) {
                    ZStack {
                        
                        VStack{
                  
                            ZStack{
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 180, height: 50)
                                    .opacity(0.7)
                                Text("Start Workout")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding()
                }
             
            }
        }
    }
    private func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
}


struct StartButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StartButton()
                .environmentObject(WeekData.shared)
                .environmentObject(WorkoutData())
        }
    }
}
